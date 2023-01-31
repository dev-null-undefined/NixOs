{
  self,
  inputs,
  ...
}: rec {
  mkHomeModules = {
    username,
    hostname,
    system ? "x86_64-linux",
  }:
    [
      (../../home + "/${username}/${hostname}.nix")
      rec {
        home.stateVersion = "22.11";
        home.username = username;

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;

        home.homeDirectory = "/home/${home.username}";
      }
    ]
    ++ (inputs.nixpkgs.lib.attrsets.mapAttrsToList (_: value: value) self.home-managerModules);

  mkHome = {
    username,
    hostname,
    system ? "x86_64-linux",
    ...
  } @ hmConfig: {
    pkgs = self.lib.internal.mkPkgsWithOverlays system;
    extraSpecialArgs = {inherit inputs self;};
    modules = mkHomeModules hmConfig;
  };
}
