{
  inputs = {
    #nixpkgs.url = "github:dev-null-undefined/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    dwm-dev-null = {
      url = "github:dev-null-undefined/dwm-flexipatch/master";
      flake = false;
    };

    nixpkgs-dev-null.url = "github:dev-null-undefined/nixpkgs/master";
    nixpkgs-webcord.url = "github:dev-null-undefined/nixpkgs/webcord";
    nixpkgs-testing.url = "github:dev-null-undefined/nixpkgs/main";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-master, nixos-hardware
    , dwm-dev-null, nixpkgs-dev-null, nixpkgs-webcord, nixpkgs-testing }@inputs:
    let
      system = "x86_64-linux";

      mkPkgs = pkgs: overlays:
        pkgs {
          inherit system;
          overlays = overlays;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ "electron-12.2.3" ];
        };

      mkOverlay = { input, name, overlays ? [ ] }:
        (final: prev: ({ "${name}" = mkPkgs (import input) overlays; }));

      pkgs = mkPkgs (import nixpkgs) [
        (mkOverlay ({
          input = nixpkgs-stable;
          name = "stable";
        }))
        (mkOverlay ({
          input = nixpkgs-dev-null;
          name = "dev-null";
        }))
        (mkOverlay ({
          input = nixpkgs-testing;
          name = "testing";
        }))
        (mkOverlay ({
          input = nixpkgs-master;
          name = "master";
        }))
        (mkOverlay ({
          input = nixpkgs-webcord;
          name = "webcord";
        }))
        (import ./custom)
      ];
    in {
      nixosConfigurations.idk = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;

        # Things in this set are passed to modules and accessible
        # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
        specialArgs = { inherit inputs; };

        modules = [
          ({ config, pkgs, ... }: {
            nix.extraOptions = "experimental-features = nix-command flakes";
            nixpkgs.config.allowUnfree = true;
          })

          nixos-hardware.nixosModules.msi-gs60

          ./configuration.nix
        ];
      };

    };
}
