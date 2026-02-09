{
  config,
  lib,
  ...
}: let
  cfg = config.generated.router;

  ipConfig = lib.types.submodule {
    options = {
      ip = lib.mkOption {
        type = lib.types.str;
        description = "IPv4 address.";
        example = "192.168.1.1";
        default = "192.168.1.1";
      };
      prefix = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Subnet prefix length (e.g., 24 for /24).";
      };
      gateway = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Gateway IP address.";
      };
    };
  };

  netPrefix = ip:
    builtins.concatStringsSep "." (
      lib.lists.dropEnd 1 (builtins.filter (x: builtins.typeOf x == "string") (builtins.split "\\." ip))
    );
in {
  options = {
    internal = {
      interface = lib.mkOption {
        type = lib.types.str;
        description = "Name of the internal interface (LAN).";
        example = "eth1";
      };

      dhcpd = let
        defaultPrefix = netPrefix cfg.internal.static.ip;
      in {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Internal DHCP server";
        };
        start = lib.mkOption {
          type = lib.types.str;
          description = "Start of the DHCP address range.";
          example = "192.168.1.100";
          default = "${defaultPrefix}.2";
        };
        end = lib.mkOption {
          type = lib.types.str;
          description = "End of the DHCP address range.";
          example = "192.168.1.200";
          default = "${defaultPrefix}.254";
        };
        dns = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to advertise this server as the DNS resolver.";
        };
      };

      static = lib.mkOption {
        type = ipConfig;
        default = {};
        description = "Static IP configuration for the internal interface.";
      };
    };

    external = {
      interface = lib.mkOption {
        type = lib.types.str;
        description = "Name of the external interface (WAN).";
        example = "eth0";
      };

      dhcp = lib.mkOption {
        type = lib.types.bool;
        default = cfg.external.static == null;
        description = "Whether to acquire an external IP via DHCP.";
      };

      static = lib.mkOption {
        type = lib.types.nullOr ipConfig;
        default = null;
        description = "Static IP configuration for the external interface (if DHCP is disabled).";
      };
    };
  };

  services.dnsmasq = lib.mkIf cfg.internal.dhcpd.enable {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      inherit (cfg.internal) interface;
      dhcp-range = "${cfg.internal.dhcpd.start},${cfg.internal.dhcpd.end},${toString cfg.internal.static.prefix}";

      dhcp-option =
        [
          "3,${
            if cfg.internal.static.gateway != null
            then cfg.internal.static.gateway
            else cfg.internal.static.ip
          }"
        ]
        ++ (lib.lists.optional cfg.internal.dhcpd.dns "6,${cfg.internal.static.ip}");

      server = config.networking.nameservers;
    };
  };

  networking.firewall = {
    allowPing = true;
    interfaces.${cfg.internal.interface} = {
      allowedUDPPorts = [
        53
        67
      ];
      allowedTCPPorts = [53];
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = cfg.external.interface;
    internalInterfaces = [cfg.internal.interface];
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.interfaces = {
    ${cfg.internal.interface} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = cfg.internal.static.ip;
          prefixLength = cfg.internal.static.prefix;
        }
      ];
    };

    ${cfg.external.interface} =
      if cfg.external.dhcp
      then {
        useDHCP = true;
      }
      else {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = cfg.external.static.ip;
            prefixLength = cfg.external.static.prefix;
          }
        ];
      };
  };

  networking.defaultGateway =
    lib.mkIf (
      !cfg.external.dhcp && cfg.external.static.gateway != null
    )
    cfg.external.static.gateway;
}
