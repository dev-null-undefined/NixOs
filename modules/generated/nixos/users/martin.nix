{
  self,
  pkgs,
  config,
  ...
}: {
  users.users.martin = {
    isNormalUser = true;
    hashedPassword = "$6$ZRbhOp8RsXm4CSqy$AtplJAXukQtMJk8cD/jEnWMyQaObP8x.kbhytD.4R4iLLJa3zHXNMzRTK1gYilfZNwU0g580/1s603ic/c.y..";
    extraGroups =
      ["wheel" "dialout" "disk"]
      ++ (self.lib'.internal.groupIfExist config [
        "network"
        "video"
        "networkmanager"
        "wireshark"
        "mysql"
        "docker"
        "libvirtd"
        "vboxusers"
        "git"
      ]);
    shell = pkgs.zsh;
    useDefaultShell = false;
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  home-manager.users = self.lib'.internal.mkHomeNixOsUser "martin" [];

  # No sudo password
  security.sudo.extraRules = [
    {
      users = ["martin"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
  ];
}
