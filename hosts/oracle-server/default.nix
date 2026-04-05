# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: {
  imports = [
    ./nginx-vhosts.nix
    ./openvpn-server.nix
    ./minecraft-forwarding.nix
    # ./bakule-vhost.nix
  ];

  generated = {
    enable = true;

    services = {
      mariadb.enable = true;
      nginx.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      prometheus.enable = true;
      atuin.enable = true;
    };
    users = {
      lomohov.enable = true;
    };
  };

  documentation.man.cache.enable = false;

  domain = config.registry.domain;

  custom.wireguard.ips = ["${config.registry.hosts.oracle-server.wgIp}/24"];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.enableIPv6 = true;
  networking.useDHCP = true;

  system.stateVersion = "22.11"; # Did you read the comment?
}
