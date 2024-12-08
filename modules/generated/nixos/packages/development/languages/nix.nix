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

  programs = {
    nix-index.enable = true;
    # Mutually exclusive with command-not-found
    command-not-found.enable = false;
    nh.enable = true;
  };

  environment.systemPackages = with pkgs;
    [
      # A ranger-like flake.lock viewer
      nix-melt

      # nix documentation
      manix

      # lsp server for nix
      nil

      # Prefetcher for sha256
      nurl

      # Automated PR testing and building
      nixpkgs-review

      # Linter
      statix

      # Nix formatters
      nixfmt-classic
      alejandra

      # Find unused variables
      deadnix

      # nix tools
      nix-diff
      # package version diff tool
      nvd

      # Build monitoring tool
      nix-output-monitor

      # dependency graphs in ranger like view
      nix-tree

      # Run packages without installing them (test drive)
      comma

      # Deployment tool
      deploy-rs
    ]
    ++ alien-pkgs
    ++ (lib.lists.optionals
      (config.services.xserver.enable || config.generated.de.enable)
      [inputs.nix-software-center.packages.${system}.nix-software-center]);
}
