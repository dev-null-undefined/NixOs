{
  pkgs,
  lib,
  ...
}: let
  # Base config used to seed ~/.codex/config.toml on first run only.
  configTemplate = pkgs.writeText "codex-config.toml" ''
    model_reasoning_effort = "xhigh"
    plan_mode_reasoning_effort = "xhigh"

    # Read CLAUDE.md files as project instructions when AGENTS.md is missing
    project_doc_fallback_filenames = ["CLAUDE.md"]
  '';
in {
  home.packages = [pkgs.codex];

  # config.toml is intentionally NOT managed as a read-only Nix store symlink:
  # Codex writes project trust entries ([projects."…"]) back to this file at
  # runtime, which fails ("config/batchWrite failed") against an immutable
  # symlink. Instead we seed it once if it doesn't exist and let Codex own it
  # afterwards. Tradeoff: changes to the base settings above won't propagate to
  # an already-seeded file — delete ~/.codex/config.toml to re-seed.
  home.activation.codexConfigSeed = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cfg="$HOME/.codex/config.toml"
    if [ ! -e "$cfg" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$cfg")"
      $DRY_RUN_CMD install -m 0644 ${configTemplate} "$cfg"
    fi
  '';

  home.file.".codex/AGENTS.md".source = ./AGENTS.md;
}
