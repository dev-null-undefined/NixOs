{
  inputs = {
    #nixpkgs.url = "github:dev-null-undefined/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.05";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
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
        nixpkgs.follows = "nixpkgs-stable";
        flake-utils.follows = "flake-utils";
      };
    };

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };
    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    nix-software-center = {
      url = "github:snowfallorg/nix-software-center";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        utils.follows = "flake-utils";
      };
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    deploy-rs,
    ...
  } @ inputs: let
    autoDetectedHosts = builtins.listToAttrs (builtins.map (hostname: {
        name = hostname;
        value = lib'.internal.ifExists (./hosts/${hostname} + "/overrides.nix");
      }) (builtins.attrNames
        (lib'.attrsets.filterAttrs (n: v: v == "directory" && n != "shared")
          (builtins.readDir ./hosts))));

    autoDetectedUsers =
      builtins.attrNames
      (lib'.attrsets.filterAttrs (_: v: v == "directory")
        (builtins.readDir ./home));

    hostConfigs = autoDetectedHosts;

    homeConfigs = builtins.foldl' (ac: cur:
      ac
      ++ (builtins.map (username:
        {
          hostname = cur.name;
        }
        // cur.value
        // {
          inherit username;
        })
      autoDetectedUsers)) [] (lib'.attrsets.attrsToList (hostConfigs
      // {
        "brnikov" = {system = "aarch64-linux";};
        "others-mc-dev-martinkos-45-136-152-121.cdn77.eu" = {};
      }));

    lib' = import ./lib {inherit inputs self;};
  in
    {
      inherit lib';
      nixosModules = import ./modules/nixos;
      home-managerModules = import ./modules/home-manager;
      overlays = import ./overlays {inherit inputs self;};

      nixosConfigurations = builtins.mapAttrs (name: value: let
        config = {hostname = name;} // value;
      in
        nixpkgs.lib.nixosSystem (lib'.internal.mkHost config)) hostConfigs;

      homeConfigurations = builtins.foldl' (acc: config:
        {
          "${config.username}@${config.hostname}" =
            home-manager.lib.homeManagerConfiguration
            (lib'.internal.mkHome config);
        }
        // acc) {}
      homeConfigs;

      deploy = {
        remoteBuild = true;
        user = "root";
        nodes =
          builtins.mapAttrs (hostname: config: {
            inherit hostname;
            profiles.system = {
              path =
                deploy-rs
                .lib
                .${
                  config.system or "x86_64-linux"
                }
                .activate
                .nixos
                self.nixosConfigurations.${hostname};
            };
          })
          hostConfigs;
      };
    }
    // (flake-utils.lib.eachDefaultSystem (system: {
      packages = lib'.internal.mkPkgsWithOverlays system;
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    }))
    // {
      templates = import ./templates;
    };
}
