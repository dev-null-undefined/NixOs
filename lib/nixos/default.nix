{
  self,
  inputs,
  ...
}: let
  inherit (self.lib'.internal) mkPkgsWithOverlays optionalPath;
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
              # harmonia is fronted by nginx bound only on homie's Tailscale IP,
              # so "homie" must resolve via Tailscale MagicDNS for substitution to work.
              # Skip on homie itself: the hostname resolves to 127.0.0.2 locally,
              # not the Tailscale IP nginx listens on.
              substituters =
                lib.optional (hostname != "homie") "http://homie:5000"
                ++ ["https://hyprland.cachix.org"];
              trusted-public-keys = [
                "homie-1:nVkPXYcuMRV5aeTf7F1coe/qFX1BrqRLmlTQBy5A6OA="
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              ];

              auto-optimise-store = true;
              keep-outputs = true;
              keep-derivations = true;

              # let remote builders use their own substituters
              builders-use-substitutes = true;
            };

            nixPath =
              lib.mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
            registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
          };

          nixpkgs.hostPlatform = lib.mkDefault system;

          generated.enable = lib.mkDefault true;
        })
        inputs.hyprland.nixosModules.default

        inputs.spicetify-nix.nixosModules.default

        inputs.sops.nixosModules.default

        inputs.lanzaboote.nixosModules.lanzaboote

        inputs.unifi-os-server.nixosModules.unifi-os-server

        # Home manager
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            extraSpecialArgs = {inherit self inputs;};
            sharedModules = [../../home/nixosDefaults.nix inputs.nixvim.homeModules.nixvim];
          };
        }

        # Host config
        (../../hosts + "/${hostname}/default.nix")
      ]
      ++ optionalPath (../../hosts + "/${hostname}/hardware-configuration.nix")
      ++ optionalPath (../../hosts + "/${hostname}/hardware-partitions.nix")
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
        [default]
        ++ optionalPath userSpecific
        ++ optionalPath hostSpecific
        ++ optionalPath nixosSpecific
        ++ optionalPath userHostSpecific
        ++ modules;
    };
  };
}
