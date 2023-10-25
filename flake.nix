{
  inputs = {
    #nixpkgs.url = "github:dev-null-undefined/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs-dev-null.url = "github:dev-null-undefined/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/thiagokokada/nix-alien
    # Run unpatched binaries on Nix/NixOS
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";

    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    ...
  } @ inputs: let
    hostConfigs = [
      {
        hostname = "idk";
      }
      {
        hostname = "oracle-server";
        system = "aarch64-linux";
      }
      {
        hostname = "brnikov";
        system = "aarch64-linux";
      }
      {hostname = "homie";}
    ];

    homeConfigs =
      builtins.map (
        config:
          config
          // {
            username = "martin";
          }
      )
      hostConfigs;

    lib' = import ./lib {inherit inputs self;};
  in
    {
      inherit lib';
      nixosModules = import ./modules/nixos;
      home-managerModules = import ./modules/home-manager;
      overlays = import ./overlays {inherit inputs self;};

      nixosConfigurations =
        builtins.foldl' (
          acc: config:
            {
              "${config.hostname}" = nixpkgs.lib.nixosSystem (lib'.internal.mkHost config);
              "${config.hostname}-vm" = nixpkgs.lib.nixosSystem (lib'.internal.mkHost (config
                // {
                  modules =
                    (config.modules or [])
                    ++ [
                      ./modules/nixos/isVM/implementation.nix
                    ];
                }));
            }
            // acc
        ) {}
        hostConfigs;
      homeConfigurations =
        builtins.foldl' (
          acc: config:
            {
              "${config.username}@${config.hostname}" =
                home-manager.lib.homeManagerConfiguration
                (lib'.internal.mkHome config);
            }
            // acc
        ) {}
        homeConfigs;
    }
    // (flake-utils.lib.eachDefaultSystem (system: {
      packages = lib'.internal.mkPkgsWithOverlays system;
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    }))
    // {
      templates = {
        clion-cpp = {
          path = ./templates/c++/clion-project;
          description = "C++ clion project with flake support";
        };
        python-shell = {
          path = ./templates/python/shell;
          description = "Simple python dev shell flake.nix file";
        };
      };
    };
}
