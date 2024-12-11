{
  pkgs,
  config,
  self,
  ...
}: let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBt3RVg6B5EfYY9uS14yfm78VEI1wUhr4sv2FYbxf6JS devnull@Devs-MacBook-Pro.local";
  dbName = "bookheaven";
in {
  users.users.samirka = {
    isNormalUser = true;
    extraGroups = self.lib'.internal.groupIfExist config [
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
    openssh.authorizedKeys.keys = [sshKey];
  };

  services.mysql = {
    ensureDatabases = [dbName];
    ensureUsers = [
      {
        name = dbName;
        ensurePermissions = {"${dbName}.*" = "ALL PRIVILEGES";};
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    6969 # UwU acka apka
    3306
  ];

  home-manager.users = self.lib'.internal.mkHomeNixOsUser "samirka" [];
}
