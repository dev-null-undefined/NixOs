# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{config, ...}: {
  imports = [./router.nix ./grafana.nix];
  generated.services = {
    ssh.enable = true;
    nextcloud.enable = true;
    unifi-docker.enable = true;
    prometheus.enable = true;
  };

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
        set_real_ip_from 10.100.0.1;
      '';

      # Setup Nextcloud virtual host to listen on ports
      virtualHosts = {
        "${config.services.nextcloud.hostName}" = {
          enableACME = false;
          forceSSL = false;
          addSSL = true;
          extraConfig = ''
            access_log  /var/log/nginx/access.log  main;
          '';
          sslCertificateKey = "/var/lib/${config.services.nextcloud.hostName}.key";
          sslCertificate = "/var/lib/${config.services.nextcloud.hostName}.crt";
        };
      };
    };
  };

  system.stateVersion = "22.11"; # Did you read the comment?
}
