{
  pkgs,
  lib,
  config,
  ...
}: let
  homeDirectory = config.home.homeDirectory;

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

  # ccstatusline — status line renderer (github.com/sirmalloc/ccstatusline).
  # Not in nixpkgs. The published npm tarball ships a single pre-bundled
  # dist/ccstatusline.js (bun build --target=node), so we just fetch + wrap with
  # node — no bun, no npm install, no build step. Bump version + hash to upgrade.
  # git is on PATH for its branch/status widgets.
  ccstatusline = let
    version = "2.2.22";
  in
    pkgs.stdenv.mkDerivation {
      pname = "ccstatusline";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-${version}.tgz";
        hash = "sha256-FKDBeocIjiP4xXxNycTAJFlr7s+I8zm+gNv9IchcsQA=";
      };
      nativeBuildInputs = [pkgs.makeWrapper];
      sourceRoot = "package"; # tarball's single top-level dir
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/libexec
        cp dist/ccstatusline.js $out/libexec/
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ccstatusline \
          --add-flags $out/libexec/ccstatusline.js \
          --prefix PATH : ${lib.makeBinPath [pkgs.git]}
        runHook postInstall
      '';
    };

  ############################################################################
  ## Claude Code profiles — single source of truth.
  ##
  ## Each profile is a Claude Code config directory (set via CLAUDE_CONFIG_DIR).
  ## This attrset drives THREE consumers from one definition:
  ##   1. shell aliases          (programs.zsh.shellAliases, below)
  ##   2. per-profile config      (CLAUDE.md / settings.json written by home.file)
  ##   3. shared-state symlinks   (non-primary profiles symlink shared items to
  ##                               the primary profile's dir)
  ##
  ## Compose rules (per-item):
  ##   - CLAUDE.md   : base text  + per-profile `claudeMdExtra` (append)
  ##   - settings.json: recursiveUpdate baseSettings `settingsExtra` (deep merge;
  ##                     covers permissions/hooks/model/effort/enabledPlugins/mcp)
  ##   - skills       : shared from the primary (in `shared.dirs`); a profile that
  ##                     wants its own set drops "skills" from shared.dirs and adds
  ##                     home.file entries — not needed yet.
  ##
  ## Anything a profile neither shares nor has Nix-defined stays as its own real,
  ## account-bound file (.credentials.json, .claude.json, policy-limits.json, ...).
  ############################################################################

  primaryName = "main";

  # Default shared set for non-primary profiles. CLAUDE.md and settings.json are
  # intentionally NOT here — they are written per-profile by home.file below.
  defaultShared = {
    dirs = [
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
    files = [
      "history.jsonl"
      ".last-cleanup"
    ];
  };

  profiles = {
    main = {
      dir = ".claude";
      primary = true;
      label = "main"; # statusline badge (phase: status line)
      color = 39; # ANSI 256 (blue-ish) — statusline badge tint
      # plain `claude`, no alias
      claudeMdExtra = "";
      settingsExtra = {};
    };
    kos = {
      dir = ".claude-kos";
      label = "kos";
      color = 203; # ANSI 256 (red-ish) — visually distinct work account
      alias = "claude-kos";
      claudeMdExtra = "\n" + builtins.readFile ./profiles/kos/CLAUDE.md;
      settingsExtra = {}; # e.g. {permissions.defaultMode = "default";} to diverge
      # shared = defaultShared;  # override to isolate e.g. projects/sessions
    };
  };

  primaryDir = profiles.${primaryName}.dir;
  nonPrimary = lib.filterAttrs (_: p: !(p.primary or false)) profiles;

  # ---- base config inherited by every profile ----
  baseClaudeMd = builtins.readFile ./CLAUDE.md;

  baseSettings = {
    skipDangerousModePermissionPrompt = true;
    skipAutoPermissionPrompt = true;
    effortLevel = "xhigh";
    voiceEnabled = false;
    spinnerTipsEnabled = false;
    preferredNotifChannel = "notifications_disabled"; # built-in off; Notification hook below handles it
    awaySummaryEnabled = false;
    theme = "dark";
    tui = "fullscreen";
    worktree.baseRef = "fresh";
    # Two-line Powerline status line (ccstatusline) reading a read-only Nix-store
    # config. Inherited by every profile from base. Tweak the look in the live TUI
    # (`ccstatusline`), then copy ~/.config/ccstatusline/settings.json over
    # ./ccstatusline-settings.json and rebuild to freeze it.
    statusLine = {
      type = "command";
      command = "${ccstatusline}/bin/ccstatusline --config ${ccstatuslineConfig}";
    };
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

  # Skills live in the primary profile's dir; non-primary profiles get them via
  # the "skills" entry in shared.dirs (symlinked below).
  baseSkills = {
    "commit/SKILL.md" = {source = ./skills/commit/SKILL.md;};
    "consolidate/SKILL.md" = {source = ./skills/consolidate/SKILL.md;};
    "grill-me/SKILL.md" = {source = ./skills/grill-me/SKILL.md;};
    "prompt-craft/SKILL.md" = {source = ./skills/prompt-craft/SKILL.md;};
    "review/SKILL.md" = {source = ./skills/review/SKILL.md;};
    "sync-config/SKILL.md" = {source = ./skills/sync-config/SKILL.md;};
    "sync-memory/SKILL.md" = {source = ./skills/sync-memory/SKILL.md;};
    "sync-memory/scripts/gather-state.sh" = {
      source = ./skills/sync-memory/scripts/gather-state.sh;
      executable = true;
    };
  };

  # ---- generated home.file entries ----
  perProfileFiles =
    lib.foldlAttrs (
      acc: _: p:
        acc
        // {
          "${p.dir}/CLAUDE.md".text = baseClaudeMd + (p.claudeMdExtra or "");
          "${p.dir}/settings.json".text =
            builtins.toJSON (lib.recursiveUpdate baseSettings (p.settingsExtra or {}));
        }
    ) {}
    profiles;

  skillFiles =
    lib.mapAttrs'
    (relPath: v: lib.nameValuePair "${primaryDir}/skills/${relPath}" v)
    baseSkills;

  # ---- generated shell aliases (non-primary profiles only) ----
  profileAliases =
    lib.foldlAttrs (
      acc: _: p:
        acc
        // lib.optionalAttrs (p ? alias) {
          ${p.alias} = "CLAUDE_CONFIG_DIR=${homeDirectory}/${p.dir} claude";
        }
    ) {}
    profiles;

  # ---- status line profile badge ----
  # Prints the active profile's label, ANSI-256-colored per profile, by matching
  # $CLAUDE_CONFIG_DIR against the profile dirs. Generated from `profiles` so the
  # status line stays in sync with the rest. The ccstatusline custom-command
  # widget calls this by name with preserveColors=true to keep the color.
  profileBadge = pkgs.writeShellApplication {
    name = "claude-profile-badge";
    text = ''
      dir="''${CLAUDE_CONFIG_DIR:-$HOME/${primaryDir}}"
      dir="''${dir%/}" # tolerate a trailing slash
      case "$dir" in
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_: p: ''
        ${p.dir} | */${p.dir}) printf '\033[38;5;${toString p.color}m%s\033[0m' ${lib.escapeShellArg p.label} ;;'')
      nonPrimary)}
        *) printf '\033[38;5;${toString profiles.${primaryName}.color}m%s\033[0m' ${lib.escapeShellArg profiles.${primaryName}.label} ;;
      esac
    '';
  };

  # Frozen ccstatusline config as a read-only store path. The repo JSON keeps
  # bare command names ("claude-profile-badge"/"hostname") so it stays editable
  # via the live TUI; here we substitute absolute store paths so the status line
  # resolves regardless of the PATH Claude Code was launched with.
  ccstatuslineConfig = pkgs.runCommand "ccstatusline-settings.json" {} ''
    substitute ${./ccstatusline-settings.json} "$out" \
      --replace-fail '"claude-profile-badge"' '"${profileBadge}/bin/claude-profile-badge"' \
      --replace-fail '"hostname"' '"${lib.getExe' pkgs.nettools "hostname"}"'
  '';

  # ---- symlink helper (non-primary <item> -> primary <item>) ----
  mkSymlink = {
    ensureTarget,
    kind,
    profileDir,
  }: name: let
    src = lib.escapeShellArg "${homeDirectory}/${primaryDir}/${name}";
    dst = lib.escapeShellArg "${profileDir}/${name}";
  in ''
    ${lib.optionalString ensureTarget "$DRY_RUN_CMD mkdir -p ${src}"}
    if [ "$(readlink ${dst} 2>/dev/null)" = ${src} ]; then
      :
    elif [ -L ${dst} ]; then
      $DRY_RUN_CMD ln -sfn ${src} ${dst}
    elif [ -e ${dst} ]; then
      echo "warning: ${dst} exists as real ${kind}; not overwriting. Migrate manually if you want it symlinked." >&2
    else
      $DRY_RUN_CMD ln -s ${src} ${dst}
    fi
  '';

  symlinkScript = lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (
      _: p: let
        profileDir = "${homeDirectory}/${p.dir}";
        shared = p.shared or defaultShared;
        mkDir = mkSymlink {
          ensureTarget = true;
          kind = "directory";
          inherit profileDir;
        };
        mkFile = mkSymlink {
          ensureTarget = false;
          kind = "file";
          inherit profileDir;
        };
      in
        ["$DRY_RUN_CMD mkdir -p ${lib.escapeShellArg profileDir}"]
        ++ map mkDir shared.dirs
        ++ map mkFile shared.files
    )
    nonPrimary));

  # ---- migration: drop the OLD shared symlinks for files that are now written
  #      per-profile by home.file, so home-manager's checkLinkTargets does not
  #      abort with "would be clobbered". Only removes symlinks, never real files.
  managedPerProfile = ["CLAUDE.md" "settings.json"];
  migrateScript = lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList (
      _: p:
        map (
          f: let
            path = lib.escapeShellArg "${homeDirectory}/${p.dir}/${f}";
          in ''
            if [ -L ${path} ]; then $DRY_RUN_CMD rm -f ${path}; fi
          ''
        )
        managedPerProfile
    )
    nonPrimary));
in {
  home.packages = [pkgs.claude-code ccstatusline profileBadge];

  home.file = perProfileFiles // skillFiles;

  programs.zsh.shellAliases = profileAliases;

  # Remove stale per-profile shared symlinks BEFORE home-manager links its files.
  home.activation.claudeProfileMigrate = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    set -eu
    ${migrateScript}
  '';

  # Wire shared state: non-primary profiles symlink their shared items to primary.
  home.activation.claudeProfileSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    ${symlinkScript}
  '';
}
