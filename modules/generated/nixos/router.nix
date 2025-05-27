{
  config,
  lib,
  ...
}: let
  cf = config.generated.router;

  internalIp = cf.dhcp.gateway;
  inherit (cf.dhcp) hosts prefix;

  internalInterface = cf.interfaces.internal;
  externalInterface = cf.interfaces.external;

  netPrefix = ip:
    builtins.concatStringsSep "." (lib.lists.dropEnd 1
      (builtins.filter (x: builtins.typeOf x == "string")
        (builtins.split "\\." ip)));

  defaultPrefix = netPrefix internalIp;
in {
  options = {
    dhcp = {
      dns = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use this server as DNS cache.";
      };
      gateway = lib.mkOption {
        type = lib.types.str;
        description = "Gateway IP as list of four integers.";
        default = "192.168.0.1";
      };
      prefix = lib.mkOption {
        type = lib.types.int;
        description = "Prefix used for the internal IP.";
        default = 24;
      };
      hosts = {
        min = lib.mkOption {
          type = lib.types.str;
          description = "Minimum host IP as list of four integers.";
          default = "${defaultPrefix}.2";
        };
        max = lib.mkOption {
          type = lib.types.str;
          description = "Maximum host IP as string.";
          default = "${defaultPrefix}.254";
        };
      };
    };
    interfaces = {
      internal = lib.mkOption {
        type = lib.types.str;
        example = "enp1s0";
        description = "Internal interface used as DHCP server NAT-ing through the external interface.";
      };
      external = lib.mkOption {
        type = lib.types.str;
        example = "enp1s0";
        description = "External interface with 'public' IP and internet access.";
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = internalInterface;
      dhcp-range = "${hosts.min},${hosts.max}";
      dhcp-option =
        ["3,${internalIp}"]
        ++ (lib.lists.optional cf.dhcp.dns "6,${internalIp}");
      server = config.networking.nameservers;
    };
  };

  networking = {
    firewall = {
      allowPing = true;
      allowedUDPPorts = [53 67];
      allowedTCPPorts = [53];
    };
    nat = {
      enable = true;
      inherit externalInterface;
      internalInterfaces = [internalInterface];
    };

    nameservers = ["1.1.1.1" "8.8.8.8"];

    # networking.enableIPv6 = true;
    useDHCP = false;
    interfaces = {
      ${externalInterface}.useDHCP = true;
      ${internalInterface}.ipv4.addresses = [
        {
          address = internalIp;
          prefixLength = prefix;
        }
      ];
    };
  };
}
