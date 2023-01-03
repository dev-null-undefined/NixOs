{
  pkgs,
  config,
  inputs,
  ...
}: let
  alien-pkgs = with inputs.nix-alien.packages.${config.nixpkgs.system}; [
    nix-alien
    nix-index-update
  ];
in {
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs;
    [
      # nix documentation
      manix

      # lsp server for nix
      nil

      # Linter
      statix

      # Nix formatter
      nixfmt

      # nix tools
      nix-diff

      # Fast searching for lib or package
      nix-index

      nix-direnv

      # Build monitoring tool
      nix-output-monitor

      # dependency graphs in ranger like view
      nix-tree
    ]
    ++ alien-pkgs;
}
