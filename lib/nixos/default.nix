{
  self,
  inputs,
  ...
}: {
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    modules ? [],
  }: {
    inherit system;
    pkgs = self.lib'.internal.mkPkgsWithOverlays system;
    specialArgs = {inherit inputs self;};
    modules =
      [
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

              # TODO: move to special folder
              substituters = ["https://hyprland.cachix.org"];
              trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];

              auto-optimise-store = true;
              keep-outputs = true;
              keep-derivations = true;
            };
            nixPath =
              lib.mapAttrsToList (k: v: "${k}=${v.to.path}")
              config.nix.registry;
            registry =
              inputs.nixpkgs.lib.mapAttrs (_: value: {flake = value;}) inputs;
            # Make use of latest `nix` to allow usage of `nix flake`s.
            # package = pkgs.nix;
          };

          nixpkgs.hostPlatform = lib.mkDefault system;

          generated.enable = lib.mkDefault true;
        })
        inputs.hyprland.nixosModules.default

        # Home manager
        inputs.home-manager.nixosModule
        {
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            extraSpecialArgs = {inherit self inputs;};
            sharedModules = [
              ../../home/nixosDefaults.nix
            ];
          };
        }

        # Host config
        (../../hosts + "/${hostname}/hardware-configuration.nix")
        (../../hosts + "/${hostname}/hardware-partitions.nix")
        (../../hosts + "/${hostname}/default.nix")
      ]
      ++ modules
      ++ (builtins.attrValues self.nixosModules);
  };

  mkHomeNixOsUser = username: {
    ${username} = {nixosConfig, ...}: let
      nixosSpecific = ../../home/${username}/nixos.nix;
      hostSpecific = ../../home/${username}/${nixosConfig.hostname}.nix;
      userSpecific = ../../home/${username}/default.nix;
      default = ../../home/default.nix;
      ifExists = file:
        if builtins.pathExists file
        then file
        else {};
    in {
      home.stateVersion = nixosConfig.system.stateVersion;
      imports = [
        (ifExists userSpecific)
        (ifExists hostSpecific)
        (ifExists nixosSpecific)
	(default)
      ];
    };
  };
}
