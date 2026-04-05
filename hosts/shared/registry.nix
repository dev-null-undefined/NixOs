{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.registry = {
    domain = mkOption {
      type = types.str;
      description = "Primary domain for public-facing services.";
    };

    tailnetDomain = mkOption {
      type = types.str;
      description = "Tailscale MagicDNS suffix. FQDN = <hostname>.<tailnetDomain>.";
    };

    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          lanIp = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "LAN IP address.";
          };
          wgIp = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "WireGuard VPN IP address (without CIDR).";
          };
          tailscaleIp = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Tailscale IP address.";
          };
        };
      });
      default = {};
      description = "Known hosts and their network addresses.";
    };

    services = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          host = mkOption {
            type = types.str;
            description = "Registry host name (key in registry.hosts).";
          };
          port = mkOption {
            type = types.port;
            description = "Port the service listens on.";
          };
          subdomain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Subdomain under registry.domain for reverse proxy.";
          };
        };
      });
      default = {};
      description = "All network-facing services and their locations.";
    };
  };

  config.registry = {
    domain = "dev-null.me";
    tailnetDomain = "rat-python.ts.net";

    hosts = {
      homie = {
        lanIp = "192.168.2.1";
        wgIp = "10.100.0.4";
        tailscaleIp = "100.103.242.75";
      };
      oracle-server = {
        wgIp = "10.100.0.1";
        tailscaleIp = "100.105.178.96";
      };
      brnikov = {
        wgIp = "10.100.0.2";
        tailscaleIp = "100.69.94.56";
      };
      prosek-wagner = {
        tailscaleIp = "100.107.165.74";
      };
      honey = {
        tailscaleIp = "100.83.239.55";
      };
      idk = {
        wgIp = "10.100.0.3";
      };
      xps = {
        wgIp = "10.100.0.5";
        tailscaleIp = "100.84.21.87";
      };
      x1 = {
        tailscaleIp = "100.111.56.12";
      };
    };

    services = {
      # User-facing services
      grafana = {
        host = "homie";
        port = 3000;
        subdomain = "grafana";
      };
      jellyfin = {
        host = "homie";
        port = 8096;
        subdomain = "jellyfin";
      };
      jellyseerr = {
        host = "homie";
        port = 5055;
        subdomain = "jellyseerr";
      };
      sonarr = {
        host = "homie";
        port = 8989;
        subdomain = "sonarr";
      };
      radarr = {
        host = "homie";
        port = 7878;
        subdomain = "radarr";
      };
      prowlarr = {
        host = "homie";
        port = 9696;
        subdomain = "prowlarr";
      };
      transmission = {
        host = "homie";
        port = 9091;
        subdomain = "transmission";
      };
      nextcloud = {
        host = "homie";
        port = 443;
        subdomain = "cloud";
      };
      unifi = {
        host = "homie";
        port = 8443;
        subdomain = "unifi";
      };
      crafty = {
        host = "homie";
        port = 8100;
        subdomain = "mc";
      };
      minecraft = {
        host = "homie";
        port = 25565;
      };

      # Home Assistant instances
      home-assistant = {
        host = "homie";
        port = 8123;
        subdomain = "home";
      };
      home-assistant-brnikov = {
        host = "brnikov";
        port = 8123;
        subdomain = "brnikov";
      };
      home-assistant-prosek = {
        host = "prosek-wagner";
        port = 8123;
        subdomain = "prosek";
      };

      # Infrastructure
      adguard = {
        host = "homie";
        port = 3380;
      };
      adguard-dns = {
        host = "homie";
        port = 53;
      };
      prometheus = {
        host = "homie";
        port = 9001;
      };
      victorialogs = {
        host = "homie";
        port = 9428;
      };
      ntopng = {
        host = "homie";
        port = 3001;
      };
      influxdb2 = {
        host = "homie";
        port = 8086;
      };
      harmonia = {
        host = "homie";
        port = 5000;
      };
      atuin = {
        host = "oracle-server";
        port = 8888;
        subdomain = "atuin";
      };
      minecraft-voice = {
        host = "homie";
        port = 33665;
      };

      # Prometheus exporters
      adguard-exporter = {
        host = "homie";
        port = 9712;
      };
      jellyfin-exporter = {
        host = "homie";
        port = 9711;
      };
      sonarr-exporter = {
        host = "homie";
        port = 9709;
      };
      radarr-exporter = {
        host = "homie";
        port = 9710;
      };
    };
  };
}
