# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: let
  r = config.registry;
  svc = r.services;
in {
  imports = [
    ./router.nix
    ./grafana.nix
  ];
  generated = {
    services = {
      ssh.enable = true;
      nextcloud.enable = true;
      unifi-docker.enable = true;
      home-assistant.enable = true;
      prometheus.enable = true;
      media.enable = true;
      smartd.enable = true;
      ntopng.enable = true;
      harmonia.enable = true;
      victorialogs.enable = true;
      adguard-home.enable = true;
      fail2ban.enable = true;
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

  services.prometheus.scrapeConfigs = [
    {
      job_name = "self-mc-server";
      static_configs = [{targets = ["127.0.0.1:19565"];}];
    }
    #    {
    #      job_name = "bakule";
    #      static_configs = [
    #        {
    #          targets = [
    #            "bc.dev-null.me:443"
    #            "bc.kubik.dev-null.me:443"
    #            "bc.posledni.dev-null.me:443"
    #          ];
    #        }
    #      ];
    #      scheme = "https";
    #    }
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
      hostName = "homie.${r.tailnetDomain}";
      home = "/var/data/nextcloud";
      settings = {
        trusted_domains = [
          r.hosts.homie.lanIp
          "${svc.nextcloud.subdomain}.${r.domain}"
        ];
        trusted_proxies = [r.hosts.oracle-server.wgIp];
      };
    };

    nginx = {
      commonHttpConfig = ''
        # Wireguard
        set_real_ip_from ${r.hosts.oracle-server.wgIp};
        # TailScale
        set_real_ip_from ${r.hosts.oracle-server.tailscaleIp};
      '';

      # Setup Nextcloud virtual host to listen on ports
      virtualHosts = {
        "${config.services.nextcloud.hostName}" = {
          enableACME = false;
          forceSSL = false;
          addSSL = true;
          sslCertificateKey = "/var/lib/${config.services.nextcloud.hostName}.key";
          sslCertificate = "/var/lib/${config.services.nextcloud.hostName}.crt";
        };
      };
    };
  };

  # Open service ports on the main LAN (services proxied via oracle-server nginx)
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
