{
  pkgs,
  config,
  self,
  ...
}: let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBt3RVg6B5EfYY9uS14yfm78VEI1wUhr4sv2FYbxf6JS devnull@Devs-MacBook-Pro.local";
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

  home-manager.users = self.lib'.internal.mkHomeNixOsUser "samirka" [];
}
