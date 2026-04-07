{pkgs, ...}: {
  home.packages = [pkgs.claude-code];

  home.file.".claude/settings.json".text = builtins.toJSON {
    skipDangerousModePermissionPrompt = true;
    effortLevel = "high";
    voiceEnabled = false;
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
  home.file.".claude/skills/review/SKILL.md".source = ./skills/review/SKILL.md;
  home.file.".claude/skills/sync-memory/SKILL.md".source = ./skills/sync-memory/SKILL.md;
}
