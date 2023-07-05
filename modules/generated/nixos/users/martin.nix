{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.martin = {
    isNormalUser = true;
    hashedPassword = "$6$ZRbhOp8RsXm4CSqy$AtplJAXukQtMJk8cD/jEnWMyQaObP8x.kbhytD.4R4iLLJa3zHXNMzRTK1gYilfZNwU0g580/1s603ic/c.y..";
    extraGroups =
      ["wheel" "dialout" "disk"]
      ++ ifTheyExist [
        "network"
        "video"
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
  security.sudo.extraRules = [
    {
      users = ["martin"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];
}
