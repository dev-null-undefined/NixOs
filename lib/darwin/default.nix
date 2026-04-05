{
  self,
  inputs,
  ...
}: let
  inherit (self.lib'.internal) mkPkgsWithOverlays optionalPath;
in {
  mkDarwinHost = {
    hostname,
    system ? "aarch64-darwin",
    modules ? [],
  }: {
    pkgs = mkPkgsWithOverlays system;
    specialArgs = {inherit inputs self;};
    modules =
      [
        ({
          lib,
          config,
          ...
        }: {
          hostname = hostname;
          nixpkgs.hostPlatform = lib.mkDefault system;

          nix = {
            settings = {
              experimental-features = ["nix-command" "flakes"];
              auto-optimise-store = true;
              keep-outputs = true;
              keep-derivations = true;
              substituters = [
                "http://homie:5000"
                "https://cache.nixos.org/"
              ];
              trusted-public-keys = [
                "homie-1:nVkPXYcuMRV5aeTf7F1coe/qFX1BrqRLmlTQBy5A6OA="
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
              trusted-users = ["@admin" config.system.primaryUser];
            };
            extraOptions = ''
              extra-platforms = x86_64-darwin aarch64-darwin
            '';
          };
        })

        # Home manager
        inputs.home-manager.darwinModules.default
        {
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            extraSpecialArgs = {inherit self inputs;};
            sharedModules = [
              ../../home/darwinDefaults.nix
              inputs.nixvim.homeModules.nixvim
            ];
          };
        }

        # Homebrew integration
        inputs.nix-homebrew.darwinModules.nix-homebrew

        # Host config
        (../../hosts + "/${hostname}/default.nix")
      ]
      ++ modules
      ++ (builtins.attrValues self.darwinModules);
  };

  mkHomeDarwinUser = username: modules: {
    ${username} = {
      osConfig,
      lib,
      ...
    }: let
      userSpecific = ../../home/${username}/default.nix;
      hostSpecific = ../../home/${username}/${osConfig.hostname}.nix;
      default = ../../home/default.nix;
    in {
      home.homeDirectory = lib.mkForce "/Users/${username}";
      home.stateVersion = "24.05";
      imports =
        [default]
        ++ optionalPath userSpecific
        ++ optionalPath hostSpecific
        ++ modules;
    };
  };
}
