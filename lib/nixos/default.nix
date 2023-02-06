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
    pkgs = self.lib.internal.mkPkgsWithOverlays system;
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
            package = pkgs.nix;
          };
          nixpkgs = {
            config.allowUnfree = true;
            hostPlatform = lib.mkDefault system;
          };
        })
        inputs.hyprland.nixosModules.default

        # Host config
        (../../hosts + "/${hostname}/hardware-configuration.nix")
        (../../hosts + "/${hostname}/hardware-partitions.nix")
        (../../hosts + "/${hostname}/default.nix")

        ../../hosts/common/default.nix
      ]
      ++ modules
      ++ (inputs.nixpkgs.lib.attrsets.mapAttrsToList (_: value: value) self.nixosModules);
  };
}
