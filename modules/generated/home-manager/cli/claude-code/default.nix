{
  pkgs,
  lib,
  config,
  ...
}: let
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
    effortLevel = "high";
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
    enabledPlugins = {
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "clangd-lsp@claude-plugins-official" = true;
      "typescript-lsp@claude-plugins-official" = true;
      "lua-lsp@claude-plugins-official" = true;
      "code-review@claude-plugins-official" = true;
      "pyright-lsp@claude-plugins-official" = true;
      "context7@claude-plugins-official" = true;
    };
  };

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
  home.file.".claude/skills/commit/SKILL.md".source = ./skills/commit/SKILL.md;
  home.file.".claude/skills/consolidate/SKILL.md".source = ./skills/consolidate/SKILL.md;
  home.file.".claude/skills/prompt-craft/SKILL.md".source = ./skills/prompt-craft/SKILL.md;
  home.file.".claude/skills/review/SKILL.md".source = ./skills/review/SKILL.md;
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
