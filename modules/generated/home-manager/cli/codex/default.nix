{pkgs, ...}: {
  home.packages = [pkgs.codex];

  home.file.".codex/config.toml".text = ''
    model_reasoning_effort = "high"

    # Read CLAUDE.md files as project instructions when AGENTS.md is missing
    project_doc_fallback_filenames = ["CLAUDE.md"]
  '';

  home.file.".codex/AGENTS.md".source = ./AGENTS.md;
}
