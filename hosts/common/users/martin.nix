{ pkgs, config, ... }:

let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.martin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "disk" ] ++ ifTheyExist [
      "network"
      "networkmanager"
      "wireshark"
      "mysql"
      "docker"
      "libvirtd"
      "vboxusers"
      "git"
    ];
    shell = pkgs.zsh;
    useDefaultShell = false;
  };

  # No sudo password 
  security.sudo.extraRules = [{
    users = [ "martin" ];
    commands = [{
      command = "ALL";
      options =
        [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
    }];
  }];
}
