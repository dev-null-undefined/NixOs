# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: {
  imports = [./router.nix ./grafana.nix];
  generated = {
    services = {
      ssh.enable = true;
      nextcloud.enable = true;
      unifi-docker.enable = true;
      home-assistant.enable = true;
      prometheus.enable = true;
      media.enable = true;
    };
    vpn.enable = true;
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "self-mc-server";
      static_configs = [{targets = ["127.0.0.1:19565"];}];
    }
    {
      job_name = "ntk";
      static_configs = [{targets = ["130.61.232.56:8000"];}];
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

  documentation.man.generateCaches = false;

  custom.wireguard.ips = ["10.100.0.4/24"];

  services = {
    nextcloud = {
      https = true;
      appstoreEnable = true;
      hostName = "homie.rat-python.ts.net";
      home = "/var/data/nextcloud";
      settings = {
        trusted_domains = ["192.168.2.1" "cloud.dev-null.me"];
        trusted_proxies = ["10.100.0.1"];
      };
    };

    nginx = {
      commonHttpConfig = ''
        # Wireguard
        set_real_ip_from 10.100.0.1;
        # TailScale
        set_real_ip_from 100.105.178.96;
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

  system.stateVersion = "22.11"; # Did you read the comment?
}
