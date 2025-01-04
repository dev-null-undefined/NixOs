{
  self,
  inputs,
  ...
}: let
  inherit (self.lib'.internal) mkPkgsWithOverlays ifExists;
in {
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    modules ? [],
  }: {
    inherit system;
    pkgs = mkPkgsWithOverlays system;
    specialArgs = {inherit inputs self;};
    modules =
      [
        ({
          config,
          lib,
          ...
        }: {
          inherit hostname;
          nix = {
            settings = {
              experimental-features = ["nix-command" "flakes"];

              trusted-users = ["root" "@wheel"];

              # TODO: move to special folder
              substituters = ["https://hyprland.cachix.org"];
              trusted-public-keys = [
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              ];

              auto-optimise-store = true;
              keep-outputs = true;
              keep-derivations = true;
            };
            nixPath =
              lib.mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
            registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
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
            sharedModules = [../../home/nixosDefaults.nix];
          };
        }

        inputs.yt-dlp-web-ui.nixosModules.default

        # Host config
        (ifExists (../../hosts + "/${hostname}/hardware-configuration.nix"))
        (ifExists (../../hosts + "/${hostname}/hardware-partitions.nix"))
        (../../hosts + "/${hostname}/default.nix")
      ]
      ++ (self.lib'.filesystem.listFilesRecursive ../../hosts/shared)
      ++ modules
      ++ (builtins.attrValues self.nixosModules);
  };

  mkHomeNixOsUser = username: modules: {
    ${username} = {nixosConfig, ...}: let
      nixosSpecific = ../../home/${username}/nixos.nix;
      userSpecific = ../../home/${username}/default.nix;
      hostSpecific = ../../home/default/${nixosConfig.hostname}.nix;
      userHostSpecific = ../../home/${username}/${nixosConfig.hostname}.nix;
      default = ../../home/default.nix;
    in {
      home.stateVersion = nixosConfig.system.stateVersion;
      imports =
        [
          (ifExists userSpecific)
          (ifExists hostSpecific)
          (ifExists nixosSpecific)
          (ifExists userHostSpecific)
          default
        ]
        ++ modules;
    };
  };
}
