{
  pkgs,
  lib,
  config,
  ...
}: let
  # ponytail — "lazy senior dev" ruleset plugin (github.com/DietrichGebert/ponytail).
  # Pinned inline so upgrades are Nix-managed: bump rev + hash here, then rebuild
  # (no flake input, no runtime `git clone`). Registered below as a read-only
  # "directory" marketplace and enabled by default; Claude Code copies it into its
  # writable plugin cache on first launch and activates it from the next session on.
  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "v4.7.0";
    hash = "sha256-Q6vlkbTfBFrNFTxEwYeMe5ciOe6QdULegvExwT//gJs=";
  };

  # Desktop-notification hook (see notify.sh). Built into the Nix store with its
  # deps pinned; referenced by absolute path from the `Notification` hook below.
  notifyHook = pkgs.writeShellApplication {
    name = "claude-code-notify";
    runtimeInputs = [pkgs.jq pkgs.libnotify pkgs.coreutils pkgs.gawk];
    text = builtins.readFile ./notify.sh;
  };

  # Items in ~/.claude-kos that should be symlinks to the matching path in
  # ~/.claude. Anything NOT listed stays as a real file in ~/.claude-kos —
  # those are credential/account-bound (.credentials.json, .claude.json,
  # settings.json, mcp-needs-auth-cache.json, policy-limits.json,
  # stats-cache.json, remote-settings.json, telemetry/).
  sharedDirs = [
    "backups"
    "cache"
    "file-history"
    "plans"
    "plugins"
    "projects"
    "session-env"
    "sessions"
    "shell-snapshots"
    "skills"
    "tasks"
    "todos"
  ];
  sharedFiles = [
    "CLAUDE.md"
    "history.jsonl"
    ".last-cleanup"
    "settings.json"
  ];

  claudeDir = "${config.home.homeDirectory}/.claude";
  kosDir = "${config.home.homeDirectory}/.claude-kos";

  # Files: do NOT pre-create the target — symlinks to non-existent paths
  # are fine, and pre-touching .last-cleanup would reset its mtime and
  # suppress Claude's cleanup logic.
  mkSymlink = {
    ensureTarget,
    kind,
  }: name: let
    src = lib.escapeShellArg "${claudeDir}/${name}";
    dst = lib.escapeShellArg "${kosDir}/${name}";
  in ''
    ${lib.optionalString ensureTarget "$DRY_RUN_CMD mkdir -p ${src}"}
    if [ "$(readlink ${dst} 2>/dev/null)" = ${src} ]; then
      :
    elif [ -L ${dst} ]; then
      $DRY_RUN_CMD ln -sfn ${src} ${dst}
    elif [ -e ${dst} ]; then
      echo "warning: ${kosDir}/${name} exists as real ${kind}; not overwriting. Migrate manually if you want it symlinked." >&2
    else
      $DRY_RUN_CMD ln -s ${src} ${dst}
    fi
  '';
  mkDirSymlink = mkSymlink {
    ensureTarget = true;
    kind = "directory";
  };
  mkFileSymlink = mkSymlink {
    ensureTarget = false;
    kind = "file";
  };
in {
  home.packages = [pkgs.claude-code];

  home.file.".claude/settings.json".text = builtins.toJSON {
    skipDangerousModePermissionPrompt = true;
    skipAutoPermissionPrompt = true;
    effortLevel = "xhigh";
    voiceEnabled = false;
    spinnerTipsEnabled = false;
    awaySummaryEnabled = false;
    theme = "dark";
    tui = "fullscreen";
    worktree.baseRef = "fresh";
    permissions = {
      defaultMode = "auto";
      allow = [
        "WebFetch(domain:github.com)"
        "WebFetch(domain:raw.githubusercontent.com)"
        "WebSearch"
      ];
    };
    hooks = {
      # Pop a desktop notification (unless this session's terminal is focused)
      # when Claude is idle, needs permission, opens an MCP dialog, or finishes auth.
      Notification = [
        {
          matcher = "idle_prompt|permission_prompt|elicitation_dialog|auth_success";
          hooks = [
            {
              type = "command";
              command = lib.getExe notifyHook;
            }
          ];
        }
      ];
    };
    extraKnownMarketplaces = {
      # Read-only marketplace served straight from the Nix store (see `ponytail` above).
      ponytail = {
        source = {
          source = "directory";
          path = "${ponytail}";
        };
      };
    };
    enabledPlugins = {
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "clangd-lsp@claude-plugins-official" = true;
      "typescript-lsp@claude-plugins-official" = true;
      "lua-lsp@claude-plugins-official" = true;
      "code-review@claude-plugins-official" = true;
      "pyright-lsp@claude-plugins-official" = true;
      "context7@claude-plugins-official" = true;
      "ponytail@ponytail" = true;
    };
  };

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
  home.file.".claude/skills/commit/SKILL.md".source = ./skills/commit/SKILL.md;
  home.file.".claude/skills/consolidate/SKILL.md".source = ./skills/consolidate/SKILL.md;
  home.file.".claude/skills/prompt-craft/SKILL.md".source = ./skills/prompt-craft/SKILL.md;
  home.file.".claude/skills/review/SKILL.md".source = ./skills/review/SKILL.md;
  home.file.".claude/skills/sync-config/SKILL.md".source = ./skills/sync-config/SKILL.md;
  home.file.".claude/skills/sync-memory/SKILL.md".source = ./skills/sync-memory/SKILL.md;
  home.file.".claude/skills/sync-memory/scripts/gather-state.sh" = {
    source = ./skills/sync-memory/scripts/gather-state.sh;
    executable = true;
  };

  home.activation.claudeKosSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg claudeDir} ${lib.escapeShellArg kosDir}
    ${lib.concatStringsSep "\n" (map mkDirSymlink sharedDirs)}
    ${lib.concatStringsSep "\n" (map mkFileSymlink sharedFiles)}
  '';
}
