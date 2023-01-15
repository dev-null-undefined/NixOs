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
    nixpkgs-testing.url = "github:dev-null-undefined/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    # https://github.com/thiagokokada/nix-alien
    # Run unpatched binaries on Nix/NixOS
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
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
    flake-utils,
    nix-alien,
  } @ inputs: let
    nixosModules = import ./modules;
    overlays = import ./overlays {inherit inputs;};
    pkgs = system: overlays.mkPkgs (import nixpkgs) (overlays.overlays system) system;

    mkHost = {
      hostname,
      system ? "x86_64-linux",
      modules ? [],
    }: {
      inherit system;
      pkgs = pkgs system;
      specialArgs = {inherit inputs;};
      modules =
        nixosModules
        ++ [
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
    nixosConfigurations = builtins.listToAttrs (builtins.concatMap (config: [
        {
          name = config.hostname;
          value = nixpkgs.lib.nixosSystem (mkHost config);
        }
        {
          name = "${config.hostname}-vm";
          value = nixpkgs.lib.nixosSystem (mkHost (config
            // {
              modules =
                nixpkgs.lib.lists.optional (config ? modules) config.modules
                ++ [
                  ./hosts/common/vm/default.nix
                ];
            }));
        }
      ])
      hostConfigs);
    formatter = builtins.listToAttrs (builtins.map (system: {
        name = system;
        value = nixpkgs.legacyPackages.${system}.alejandra;
      })
      flake-utils.lib.defaultSystems);
  };
}
