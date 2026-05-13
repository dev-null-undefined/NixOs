# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: let
  r = config.registry;
  svc = r.services;
in {
  domain = config.registry.domain;
  imports = [
    ./router.nix
    ./grafana.nix
    ./nginx-vhosts.nix
  ];
  generated = {
    services = {
      ssh.enable = true;
      nextcloud.enable = true;
      unifi.enable = true;
      home-assistant.enable = true;
      prometheus.enable = true;
      media.enable = true;
      smartd.enable = true;
      ntopng.enable = true;
      harmonia.enable = true;
      victorialogs.enable = true;
      acme.enable = true;
      adguard-home.enable = true;
      atuin.enable = true;
      fail2ban.enable = true;
      minecraft.enable = true;
      tailscale.prometheus.enable = true;
    };
    vpn.enable = true;
  };

  services.ntopng.interfaces = [
    "enp1s0"
    "enp6s0"
    "veth0"
    "wg0"
    "vlan500"
    "vlan300"
    "vlan100"
    "tailscale0"
    "docker0"
  ];

  services.prometheus.scrapeConfigs = let
    mkTarget = name: let s = svc.${name}; in "${r.hosts.${s.host}.tailscaleIp}:${toString s.port}";
  in [
    {
      job_name = "self-mc-server";
      static_configs = [{targets = ["127.0.0.1:19565"];}];
    }
    {
      job_name = "remote-node";
      static_configs = [
        {
          targets = map mkTarget ["node-exporter-oracle" "node-exporter-prosek" "node-exporter-brnikov"];
        }
      ];
    }
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  documentation.man.cache.enable = false;

  custom.wireguard.ips = ["${r.hosts.homie.wgIp}/24"];

  services = {
    nextcloud = {
      https = true;
      appstoreEnable = true;
      home = "/var/data/nextcloud";
      settings = {
        trusted_domains = [
          r.hosts.homie.lanIp
          "homie.${r.tailnetDomain}"
        ];
        trusted_proxies = ["127.0.0.1"];
      };
    };

    nginx.virtualHosts.${config.services.nextcloud.hostName}.http3 = true;
  };

  # Open service ports on the main LAN for direct access (bypassing nginx)
  networking.firewall.interfaces.${config.generated.router.vlans.main.vlanInterface}.allowedTCPPorts = map (name: svc.${name}.port) [
    "jellyseerr"
    "radarr"
    "jellyfin"
    "crafty"
    "home-assistant"
    "sonarr"
    "transmission"
    "prowlarr"
  ];

  system.stateVersion = "22.11"; # Did you read the comment?
}
