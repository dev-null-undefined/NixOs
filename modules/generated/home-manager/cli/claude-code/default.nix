{pkgs, ...}: {
  home.packages = [pkgs.claude-code];

  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      skipDangerousModePermissionPrompt = true;
      effortLevel = "high";
    };
  };

  home.file.".claude/skills/commit/SKILL.md".source = ./skills/commit/SKILL.md;
}
