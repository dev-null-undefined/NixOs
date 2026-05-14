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
            description = "Public port the service is reached on.";
          };
          internalPort = mkOption {
            type = types.nullOr types.port;
            default = null;
            description = "Internal port the application binds to when fronted by a reverse proxy. Null means the service is direct (uses `port`).";
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

    values = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Free-form shared constants (e.g. authorized SSH keys, public keys, well-known IDs).";
    };
  };
}
