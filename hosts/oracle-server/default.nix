# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ./nginx-vhosts.nix
    ./openvpn-server.nix
    ./minecraft-forwarding.nix
  ];

  generated = {
    enable = true;

    services = {
      mariadb.enable = true;
      nextcloud.enable = true;
      nginx.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      wireguard.enable = true;
    };
    users.lomohov.enable = true;
  };

  domain = "dev-null.me";


  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.enableIPv6 = true;
  networking.useDHCP = true;

  system.stateVersion = "22.11"; # Did you read the comment?
}
