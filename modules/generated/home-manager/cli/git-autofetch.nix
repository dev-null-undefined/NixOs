{lib, ...}: {
  programs.zsh.initContent = lib.mkAfter ''
    # Auto git-fetch on cd, then auto-pop an interactive y/N suggestion when the
    # fetch finishes IF the user is sitting at an empty prompt. Behavior:
    #   • Foreground process running (claude-code, vim, ssh…) → never interrupts.
    #     TMOUT/ALRM only fires while zsh is waiting for the next command.
    #   • Buffer has typed-but-unsubmitted text → skip, retry next tick.
    #   • Buffer empty → show suggestion + y/N inline above the prompt.
    # Fetch is async + rate-limited (5 min/repo).

    typeset -g __git_autofetch_cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/git-autofetch"
    command mkdir -p "$__git_autofetch_cache_dir"
    typeset -g __git_autofetch_pending=""

    # Print "cmd|status" or nothing.
    __git_autofetch_compute() {
      local repo="$1"
      [[ -z "$repo" ]] && return

      local upstream counts ahead behind dirty="" has_fixup=""
      upstream=$(command git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || return
      counts=$(command git -C "$repo" rev-list --left-right --count "HEAD...@{u}" 2>/dev/null) || return
      ahead=''${counts%%	*}
      behind=''${counts##*	}

      command git -C "$repo" diff-index --quiet HEAD -- 2>/dev/null || dirty=1

      (( behind == 0 )) && return

      if (( ahead > 0 )); then
        if command git -C "$repo" log "@{u}..HEAD" --format=%s 2>/dev/null | grep -qE '^(fixup|squash)!'; then
          has_fixup=1
        fi
      fi

      local cmd
      local -a flags
      if (( ahead == 0 )); then
        cmd="git pull"
      else
        cmd="git pull --rebase"
        [[ -n "$has_fixup" ]] && flags+=(--autosquash)
      fi

      if [[ -n "$dirty" ]]; then
        [[ "$cmd" != *--rebase* ]] && cmd="git pull --rebase"
        flags+=(--autostash)
      fi

      (( ''${#flags[@]} > 0 )) && cmd="$cmd ''${flags[*]}"

      local status="''${behind} behind"
      (( ahead > 0 )) && status="$status, ''${ahead} ahead"
      [[ -n "$dirty" ]] && status="$status, dirty"
      status="$status vs $upstream"

      print -r -- "$cmd|$status"
    }

    # Show suggestion, read y/N (8s timeout), run on y/Y.
    __git_autofetch_ask() {
      local repo="$1"
      local result
      result=$(__git_autofetch_compute "$repo")
      [[ -z "$result" ]] && return

      local cmd="''${result%%|*}"
      local status="''${result##*|}"

      print
      print -P "%F{yellow}⇊ git: $status%f"
      print -P "%F{cyan}  → %B$cmd%b%f"

      local reply=""
      if read -t 8 -k 1 'reply?  Run? [y/N] '; then
        print
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
          print -P "%F{green}▶ running: $cmd%f"
          eval "$cmd"
          local rc=$?
          if (( rc == 0 )); then
            print -P "%F{green}✓ done%f"
          else
            print -P "%F{red}✗ exit $rc%f"
          fi
        else
          print -P "%F{8}  skipped%f"
        fi
      else
        print
        print -P "%F{8}  (no response, skipped)%f"
      fi
    }

    # Returns 0 if a pending fetch was consumed (whether we showed UI or not).
    __git_autofetch_try_consume() {
      [[ -z "$__git_autofetch_pending" ]] && return 1
      local cache_key="''${__git_autofetch_pending//\//_}"
      local done_file="$__git_autofetch_cache_dir/$cache_key.done"
      [[ -f "$done_file" ]] || return 1
      command rm -f "$done_file"

      local repo="$__git_autofetch_pending"
      __git_autofetch_pending=""
      TMOUT=0

      local current
      current=$(command git rev-parse --show-toplevel 2>/dev/null)
      [[ "$current" != "$repo" ]] && return 0

      __git_autofetch_ask "$repo"
      return 0
    }

    __git_autofetch_chpwd() {
      local top
      top=$(command git rev-parse --show-toplevel 2>/dev/null) || return

      local cache_key="''${top//\//_}"
      local cache_file="$__git_autofetch_cache_dir/$cache_key"
      local now=$EPOCHSECONDS
      local last=0
      [[ -f "$cache_file" ]] && last=$(< "$cache_file")

      if (( now - last < 300 )); then
        # Rate-limited path: ask synchronously, no polling needed.
        __git_autofetch_ask "$top"
        return
      fi

      print -r -- "$now" > "$cache_file"
      __git_autofetch_pending="$top"
      TMOUT=1

      (
        cd "$top" && command git fetch --quiet --all --prune 2>/dev/null
        : > "$cache_file.done"
      ) &!
    }

    # Fallback path: catches a finished fetch after the user runs any command.
    __git_autofetch_precmd() {
      __git_autofetch_try_consume
    }

    # Main path: fires when shell is idle at the prompt. Skips while user is
    # typing (BUFFER non-empty) — they'll be caught next tick or via precmd.
    TRAPALRM() {
      [[ -z "$__git_autofetch_pending" ]] && { TMOUT=0; return; }
      [[ -n "$BUFFER" ]] && return
      if __git_autofetch_try_consume; then
        zle reset-prompt 2>/dev/null
      fi
    }

    zmodload zsh/datetime 2>/dev/null
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd __git_autofetch_chpwd
    add-zsh-hook precmd __git_autofetch_precmd

    # Trigger once for the initial directory at shell start.
    __git_autofetch_chpwd
  '';
}
