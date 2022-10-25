{ pkgs, ... }: {
  users.users.martin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      "docker"
      "libvirtd"
      "disk"
      "vboxusers"
      "wireshark"
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
