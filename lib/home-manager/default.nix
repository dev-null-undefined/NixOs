{
  self,
  inputs,
  ...
}: rec {
  mkHomeModules = {
    username,
    hostname,
    ...
  }: let
    standAlonePath = ../../home + "/${username}/${hostname}.nix";
  in
    [
      (
        if builtins.pathExists standAlonePath
        then standAlonePath
        else {}
      )
      (../../home + "/${username}/default.nix")
      ({pkgs, ...}: rec {
        home.stateVersion = "22.11";
        home.username = username;

        #Let Home Manager install and manage itself.
        programs.home-manager.enable = true;

        imports = [inputs.hyprland.homeManagerModules.default];
        home.homeDirectory = "/home/${home.username}";

        nix = {
          package = pkgs.nixFlakes;
          extraOptions = ''
            experimental-features = nix-command flakes
          '';
        };
      })
    ]
    ++ (builtins.attrValues self.home-managerModules);

  mkHome = {system ? "x86_64-linux", ...} @ hmConfig: {
    pkgs = self.lib'.internal.mkPkgsWithOverlays system;
    extraSpecialArgs = {inherit inputs self;};
    modules = mkHomeModules hmConfig;
  };
}
