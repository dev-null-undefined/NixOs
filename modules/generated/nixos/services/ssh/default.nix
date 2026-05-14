{
  lib,
  self,
  ...
}: let
  sshKeys = import (self.outPath + "/lib/ssh-keys.nix");
in {
  services.openssh = {
    enable = true;
    ports = [22 8022];
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      X11Forwarding = true;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = sshKeys;
  };
}
