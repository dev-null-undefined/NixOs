{
  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
      nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=nixos-21.11";
      nixpkgs-master.url = "github:NixOS/nixpkgs?ref=master";
      nixos-hardware.url = "github:dev-null-undefined/nixos-hardware/master";
  };

  outputs = { self,
              nixpkgs,
              nixpkgs-stable,
              nixpkgs-master,
              nixos-hardware,
              ...
            }@inputs:
  let
      system = "x86_64-linux";
      overlay-master = final: prev: {
          master = import nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };
        }; 
      overlay-stable = final: prev: {
          stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        }; 
  in with nixpkgs.lib; {
    nixosConfigurations.idk = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ overlay-stable overlay-master ];
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixFlakes;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
        })

       nixos-hardware.nixosModules.msi-gs60
  
        ./configuration.nix
      ];
    };

  };
}
