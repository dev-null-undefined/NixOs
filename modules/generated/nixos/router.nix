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

  clientConfig = lib.types.submodule {
    options = {
      mac = lib.mkOption {
        type = lib.types.str;
        description = "MAC address of the client.";
        example = "6b:e9:ca:0a:03:04";
      };
      ip = lib.mkOption {
        type = lib.types.str;
        description = "Static IP address to assign.";
        example = "192.168.1.102";
      };
    };
  };

  netPrefix = ip:
    builtins.concatStringsSep "." (
      lib.lists.dropEnd 1 (builtins.filter (x: builtins.typeOf x == "string") (builtins.split "\\." ip))
    );

  vlans = cfg.vlans;
  vlanNames = builtins.attrNames vlans;

  # Filtered VLAN sets
  dhcpEnabled = lib.filterAttrs (_: v: v.dhcp.enable) vlans;
  natEnabled = lib.filterAttrs (_: v: v.policy.nat) vlans;
  isolated = lib.filterAttrs (_: v: v.policy.isolated) vlans;
  nonIsolated = lib.filterAttrs (_: v: !v.policy.isolated) vlans;
  routerAccess = lib.filterAttrs (_: v: v.policy.routerAccess) vlans;

  # Duplicate VLAN ID detection
  vlanIdsWithTags = lib.filter (x: x != null) (lib.mapAttrsToList (_: v: v.id) vlans);
in {
  options = {
    vlans = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: let
        selfCfg = cfg.vlans.${name};
        defaultPrefix = netPrefix selfCfg.static.ip;
      in {
        options = {
          id = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "802.1Q VLAN tag. null = untagged (use interface directly).";
          };

          interface = lib.mkOption {
            type = lib.types.str;
            description = "Physical interface (trunk parent if id is set).";
            example = "enp1s0";
          };

          vlanInterface = lib.mkOption {
            type = lib.types.str;
            default =
              if selfCfg.id == null
              then selfCfg.interface
              else "vlan${toString selfCfg.id}";
            description = "Network interface name used for this VLAN. Auto-derived from id/interface but can be overridden.";
          };

          static = lib.mkOption {
            type = ipConfig;
            default = {};
            description = "Static IP configuration for the router on this VLAN.";
          };

          dhcp = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable DHCP server on this VLAN.";
            };
            start = lib.mkOption {
              type = lib.types.str;
              default = "${defaultPrefix}.2";
              description = "Start of DHCP address range.";
            };
            end = lib.mkOption {
              type = lib.types.str;
              default = "${defaultPrefix}.254";
              description = "End of DHCP address range.";
            };
            dns = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to advertise this server as the DNS resolver.";
            };
            leaseTime = lib.mkOption {
              type = lib.types.str;
              default = "12h";
              description = "DHCP lease time (dnsmasq syntax, e.g. \"12h\", \"30m\", \"infinite\").";
            };
            staticLeases = lib.mkOption {
              type = lib.types.attrsOf clientConfig;
              default = {};
              description = "Map of hostnames to static IP/MAC configurations.";
            };
          };

          policy = {
            nat = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Allow NAT to internet.";
            };
            isolated = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Block traffic to/from other VLANs.";
            };
            allowedVlans = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "VLANs that this isolated VLAN may communicate with.";
            };
            routerAccess = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Allow devices on this VLAN to reach the router (DNS/DHCP/management).";
            };
          };
        };
      }));
      default = {};
      description = "Per-VLAN configuration for the router.";
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

  # 1. networking.vlans — tagged VLAN interfaces
  networking.vlans = lib.foldl' (acc: name: let
    v = vlans.${name};
  in
    if v.id != null
    then
      acc
      // {
        "vlan${toString v.id}" = {
          id = v.id;
          interface = v.interface;
        };
      }
    else acc) {}
  vlanNames;

  # 2. networking.interfaces — static IPs for each VLAN + external
  networking.interfaces =
    (lib.foldl' (acc: name: let
      v = vlans.${name};
    in
      acc
      // {
        ${v.vlanInterface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = v.static.ip;
              prefixLength = v.static.prefix;
            }
          ];
        };
      }) {}
    vlanNames)
    // {
      ${cfg.external.interface} =
        if cfg.external.dhcp
        then {useDHCP = true;}
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

  # 3. services.dnsmasq — single instance serving all DHCP-enabled VLANs
  services.dnsmasq = let
    dhcpNames = builtins.attrNames dhcpEnabled;
    hasDhcp = dhcpNames != [];
  in
    lib.mkIf hasDhcp {
      enable = true;
      alwaysKeepRunning = true;
      settings = {
        bind-interfaces = true;

        interface = builtins.map (name: dhcpEnabled.${name}.vlanInterface) dhcpNames;

        dhcp-range = builtins.map (name: let
          v = dhcpEnabled.${name};
        in "interface:${v.vlanInterface},${v.dhcp.start},${v.dhcp.end},${v.dhcp.leaseTime}")
        dhcpNames;

        dhcp-option = builtins.concatMap (name: let
          v = dhcpEnabled.${name};
          gw =
            if v.static.gateway != null
            then v.static.gateway
            else v.static.ip;
        in
          ["interface:${v.vlanInterface},3,${gw}"]
          ++ (lib.optional v.dhcp.dns "interface:${v.vlanInterface},6,${v.static.ip}"))
        dhcpNames;

        dhcp-host = builtins.concatMap (name: let
          v = dhcpEnabled.${name};
        in
          lib.mapAttrsToList
          (hostname: client: "${client.mac},${hostname},${client.ip}")
          v.dhcp.staticLeases)
        dhcpNames;

        quiet-dhcp = true;
        dhcp-authoritative = true;
        port = 0; # Disable DNS — handled by AdGuard Home
      };
    };

  # 4. networking.nat
  networking.nat = {
    enable = true;
    externalInterface = cfg.external.interface;
    internalInterfaces = lib.mapAttrsToList (_: v: v.vlanInterface) natEnabled;
  };

  # 5. networking.firewall
  networking.firewall = let
    # INPUT: per-interface DNS/DHCP ports
    ifaceRules = lib.foldl' (acc: name: let
      v = routerAccess.${name};
    in
      acc
      // {
        ${v.vlanInterface} = {
          allowedUDPPorts = [53 67];
          allowedTCPPorts = [53];
        };
      }) {}
    (builtins.attrNames routerAccess);

    # FORWARD rules (nftables syntax)
    extIf = cfg.external.interface;

    # Non-isolated VLANs: accept to external + accept between each other
    nonIsolatedNames = builtins.attrNames nonIsolated;
    nonIsolatedIfNames = builtins.map (n: nonIsolated.${n}.vlanInterface) nonIsolatedNames;

    nonIsolatedForwardRules = builtins.concatMap (ifName:
      ["iifname \"${ifName}\" oifname \"${extIf}\" accept"]
      ++ builtins.map (otherIfName: "iifname \"${ifName}\" oifname \"${otherIfName}\" accept")
      (builtins.filter (other: other != ifName) nonIsolatedIfNames))
    nonIsolatedIfNames;

    # Isolated VLANs: accept to external (if nat), accept to allowedVlans, drop rest
    isolatedNames = builtins.attrNames isolated;

    isolatedAcceptRules = builtins.concatMap (name: let
      v = isolated.${name};
    in
      (lib.optional v.policy.nat
        "iifname \"${v.vlanInterface}\" oifname \"${extIf}\" accept")
      ++ builtins.map (allowedName: "iifname \"${v.vlanInterface}\" oifname \"${vlans.${allowedName}.vlanInterface}\" accept")
      v.policy.allowedVlans)
    isolatedNames;

    isolatedDropRules = builtins.map (name: let
      v = isolated.${name};
    in "iifname \"${v.vlanInterface}\" drop")
    isolatedNames;

    allForwardRules =
      ["ct state established,related accept"]
      ++ nonIsolatedForwardRules
      ++ isolatedAcceptRules
      ++ isolatedDropRules;
  in {
    allowPing = true;
    filterForward = true;
    interfaces = ifaceRules;
    extraForwardRules = builtins.concatStringsSep "\n" allForwardRules;
  };

  # 6. networking.defaultGateway + nameservers
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  networking.defaultGateway =
    lib.mkIf
    (!cfg.external.dhcp && cfg.external.static.gateway != null)
    cfg.external.static.gateway;

  # Assertions
  assertions = let
    # VLAN IDs between 1-4094
    vlanIdRange =
      builtins.map (name: let
        v = vlans.${name};
      in {
        assertion = v.id == null || (v.id >= 1 && v.id <= 4094);
        message = "VLAN '${name}' has invalid ID ${toString (v.id or 0)}. Must be between 1 and 4094.";
      })
      vlanNames;

    # No duplicate VLAN IDs
    duplicateIds = [
      {
        assertion = (builtins.length (lib.unique vlanIdsWithTags)) == (builtins.length vlanIdsWithTags);
        message = "Duplicate VLAN IDs detected.";
      }
    ];

    # allowedVlans entries reference existing VLAN names
    allowedVlansExist = builtins.concatMap (name: let
      v = vlans.${name};
    in
      builtins.map (allowed: {
        assertion = builtins.hasAttr allowed vlans;
        message = "VLAN '${name}' references non-existent VLAN '${allowed}' in allowedVlans.";
      })
      v.policy.allowedVlans)
    vlanNames;

    # Isolated VLANs with allowedVlans referencing another isolated VLAN must be mutual
    mutualAllowed = builtins.concatMap (name: let
      v = vlans.${name};
    in
      builtins.concatMap (allowed: let
        allowedV = vlans.${allowed} or {};
      in
        lib.optional ((allowedV.policy.isolated or false) && !(builtins.elem name (allowedV.policy.allowedVlans or []))) {
          assertion = false;
          message = "VLAN '${name}' allows isolated VLAN '${allowed}' but '${allowed}' does not allow '${name}' back. Isolated VLAN allowedVlans must be mutual.";
        })
      v.policy.allowedVlans)
    (builtins.attrNames isolated);
  in
    vlanIdRange ++ duplicateIds ++ allowedVlansExist ++ mutualAllowed;
}
