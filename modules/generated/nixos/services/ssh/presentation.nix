{
  self,
  lib,
  pkgs,
  ...
}: let
  users = builtins.map (x: "presentation-" + builtins.toString x) (lib.lists.range 0 20);
  createUser = userName: {
    ${userName} = {
      isNormalUser = true;
      initialPassword = "nixos";
      shell = pkgs.zsh;
      useDefaultShell = false;
    };
  };
  createHome = user: self.lib'.internal.mkHomeNixOsUser user [];
  createUsers = users: creator: builtins.foldl' (acc: user: acc // user) {} (builtins.map creator users);
in {
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  users.users = createUsers users createUser;
  home-manager.users = createUsers users createHome;
}
