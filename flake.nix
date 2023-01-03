{
  inputs = {
    #nixpkgs.url = "github:dev-null-undefined/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    dwm-dev-null = {
      url = "github:dev-null-undefined/dwm-flexipatch/master";
      flake = false;
    };

    nixpkgs-dev-null.url = "github:dev-null-undefined/nixpkgs/master";
    nixpkgs-webcord.url = "github:dev-null-undefined/nixpkgs/webcord";
    nixpkgs-testing.url = "github:dev-null-undefined/nixpkgs/jetbrains-update";

    # https://github.com/thiagokokada/nix-alien
    # Run unpatched binaries on Nix/NixOS
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-master,
    nixos-hardware,
    dwm-dev-null,
    nixpkgs-dev-null,
    nixpkgs-webcord,
    nixpkgs-testing,
    nix-alien,
  } @ inputs: let
    mkPkgs = pkgs: overlays: system:
      pkgs {
        inherit system;
        overlays = overlays;
        config.allowUnfree = true;
        config.permittedInsecurePackages = ["electron-12.2.3"];
      };

    mkOverlay = {
      input ? inputs."nixpkgs-${name}",
      name,
      overlays ? [],
      system,
    }: (final: prev: {"${name}" = mkPkgs (import input) overlays system;});

    pkgs = system:
      mkPkgs (import nixpkgs) [
        (mkOverlay {
          inherit system;
          name = "stable";
        })
        (mkOverlay {
          inherit system;
          name = "dev-null";
        })
        (mkOverlay {
          inherit system;
          name = "testing";
        })
        (mkOverlay {
          inherit system;
          name = "master";
        })
        (mkOverlay {
          inherit system;
          name = "webcord";
        })
        (import ./pkgs)
      ]
      system;

    mkHost = {
      hostname,
      system ? "x86_64-linux",
      modules ? [],
    }: {
      inherit system;
      pkgs = pkgs system;
      specialArgs = {inherit inputs;};
      modules =
        [
          ./modules/grub-savedefault.nix
          ./modules/hostname.nix
          ({
            config,
            lib,
            pkgs,
            ...
          }: {
            inherit hostname;
            nix = {
              settings = {
                experimental-features = ["nix-command" "flakes"];
                auto-optimise-store = true;
                keep-outputs = true;
                keep-derivations = true;
              };
              nixPath =
                lib.mapAttrsToList (k: v: "${k}=${v.to.path}")
                config.nix.registry;
              registry =
                nixpkgs.lib.mapAttrs (_: value: {flake = value;}) inputs;
              # Make use of latest `nix` to allow usage of `nix flake`s.
              package = pkgs.nix;
            };
            nixpkgs.config.allowUnfree = true;
          })
          (./hosts + "/${hostname}/hardware-configuration.nix")
          (./hosts + "/${hostname}/default.nix")
          ./hosts/common/default.nix
        ]
        ++ modules;
    };

    hostConfigs = [
      {hostname = "idk";}
      {
        hostname = "oracle-server";
        system = "aarch64-linux";
      }
    ];
  in {
    nixosConfigurations = builtins.listToAttrs (builtins.map (config: {
        name = config.hostname;
        value = nixpkgs.lib.nixosSystem (mkHost config);
      })
      hostConfigs);
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
