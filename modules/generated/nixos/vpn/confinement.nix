{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  # --- Config shorthand + extracted option values ---
  cf = config.generated.vpn.confinement;
  inherit (cf) netnsName outIface;
  inherit (cf.vpn) serverIP serverPort peerPublicKey interfaceIP dns privateKeySecret;

  # --- Veth addresses ---
  veth = {
    subnet = "10.200.200";
    hostIP = "10.200.200.1";
    nsIP = "10.200.200.2";
    cidr = "10.200.200.0/24";
  };

  # --- nftables rule generators ---
  protoList = protocol:
    if protocol == "both"
    then ["tcp" "udp"]
    else [protocol];

  openPortRules = builtins.concatMap ({
    port,
    protocol,
  }:
    builtins.map (proto: "    iifname \"veth1\" ${proto} dport ${toString port} accept")
    (protoList protocol))
  cf.openPorts;

  dnatRules = builtins.concatMap ({
    from,
    to,
    protocol,
  }:
    builtins.map (proto: "    ${proto} dport ${toString from} dnat to ${veth.nsIP}:${toString to}")
    (protoList protocol))
  cf.portMappings;

  # --- nftables config files ---
  netnsNftConf = pkgs.writeText "${netnsName}-netns-nft.conf" ''
    table inet filter {
      chain input {
        type filter hook input priority filter; policy drop;
        iifname "lo" accept
        ct state established,related accept
        iifname "wg-${netnsName}" accept
    ${builtins.concatStringsSep "\n" openPortRules}
      }
      chain output {
        type filter hook output priority filter; policy drop;
        oifname "lo" accept
        ct state established,related accept
        oifname "wg-${netnsName}" accept
        oifname "veth1" ip daddr ${serverIP} udp dport ${toString serverPort} accept
      }
      chain forward {
        type filter hook forward priority filter; policy drop;
      }
    }
  '';
  # --- nftables rule formatting for declarative table ---
  dnatRulesStr = builtins.concatStringsSep "\n    " dnatRules;
in {
  options = {
    vpn = {
      serverIP = lib.mkOption {
        type = lib.types.str;
        default = "146.70.129.18";
        description = "VPN server IP address.";
      };
      serverPort = lib.mkOption {
        type = lib.types.port;
        default = 51820;
        description = "VPN server port.";
      };
      peerPublicKey = lib.mkOption {
        type = lib.types.str;
        default = "sDVKmYDevvGvpKNei9f2SDbx5FMFi6FqBmuRYG/EFg8=";
        description = "WireGuard peer public key.";
      };
      interfaceIP = lib.mkOption {
        type = lib.types.str;
        default = "10.2.0.2/32";
        description = "IP assigned by the VPN provider.";
      };
      dns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["10.2.0.1"];
        description = "DNS servers for the VPN namespace.";
      };
      privateKeySecret = lib.mkOption {
        type = lib.types.str;
        default = "protonvpn-wireguard-pk";
        description = "SOPS secret name for the WireGuard private key.";
      };
    };
    netnsName = lib.mkOption {
      type = lib.types.str;
      default = "protonvpn";
      description = "Network namespace name.";
    };
    outIface = lib.mkOption {
      type = lib.types.str;
      default = config.generated.router.external.interface;
      description = "Interface used for NATing the namespace through.";
    };
    openPorts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "The port to open.";
          };
          protocol = lib.mkOption {
            default = "tcp";
            example = "both";
            type = lib.types.enum ["tcp" "udp" "both"];
            description = "The transport layer protocol to use.";
          };
        };
      });
      default = [];
      description = "Ports that should be accessible through the netns.";
    };
    portMappings = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          from = lib.mkOption {
            example = 80;
            type = lib.types.port;
            description = "Port on the default netns.";
          };
          to = lib.mkOption {
            example = 443;
            type = lib.types.port;
            description = "Port on the VPN netns.";
          };
          protocol = lib.mkOption {
            default = "tcp";
            example = "both";
            type = lib.types.enum ["tcp" "udp" "both"];
            description = "The transport layer protocol to use.";
          };
        };
      });
      default = [];
      description = "A list of port mappings from the host to ports in the namespace.";
      example = [
        {
          from = 80;
          to = 80;
          protocol = "tcp";
        }
      ];
    };
  };

  # Host-side NAT + DNAT — managed by NixOS nftables, survives firewall reloads
  networking.nftables.tables."vpn-${netnsName}" = {
    family = "ip";
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr ${veth.cidr} oifname "${outIface}" masquerade
        ct status dnat oifname "veth0" masquerade
      }
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
        ${dnatRulesStr}
      }
    '';
  };

  generated.vpn.confinement.openPorts =
    builtins.map (mapping: {
      port = mapping.to;
      inherit (mapping) protocol;
    })
    cf.portMappings;

  systemd.services."${netnsName}-netns" = {
    description = "Set up ${netnsName} network namespace and firewall";
    wantedBy = ["multi-user.target"];
    before = ["${netnsName}-vpn.service"];

    path = with pkgs; [nftables iproute2 nettools coreutils];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = pkgs.writeShellScript "${netnsName}-netns-stop" ''
        NS="${netnsName}"

        # Clean up nftables in netns
        ip netns exec "$NS" nft flush ruleset || true

        # Remove namespace
        ip netns del "$NS" || true

        # Remove veth interfaces
        ip link delete veth0 || true
      '';
      ExecStart = pkgs.writeShellScript "${netnsName}-netns-start" ''
        NS="${netnsName}"
        HOST_IP="${veth.hostIP}"
        NS_IP="${veth.nsIP}"
        SERVER_IP="${serverIP}"

        # Create namespace
        ip netns add "$NS" || true

        # Set up veth pair
        ip link show veth0 || ip link add veth0 type veth peer name veth1
        ip link set veth1 netns "$NS"
        ip addr add "$HOST_IP/24" dev veth0 || true
        ip link set veth0 up

        # Configure namespace networking
        ip netns exec "$NS" ip addr add "$NS_IP/24" dev veth1 || true
        ip netns exec "$NS" ip link set veth1 up
        ip netns exec "$NS" ip link set lo up
        ip netns exec "$NS" ip route add default via "$HOST_IP" || true
        ip netns exec "$NS" ip route add "$SERVER_IP/32" via "$HOST_IP" dev veth1 || true

        # Netns firewall
        ip netns exec "$NS" nft -f ${netnsNftConf}
      '';
    };
  };

  environment.etc."netns/${netnsName}/resolv.conf" = {
    text =
      builtins.concatStringsSep "\n"
      (builtins.map (ns: "nameserver ${ns}") (dns ++ ["1.1.1.1"]))
      + "\n";
    mode = "0644";
  };

  sops.secrets.${privateKeySecret} = {
    sopsFile = self.outPath + "/secrets/${privateKeySecret}";
    format = "binary";
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      "wg-${netnsName}" = {
        socketNamespace = netnsName;
        interfaceNamespace = netnsName;
        ips = [interfaceIP];

        listenPort = serverPort;

        privateKeyFile = config.sops.secrets.${privateKeySecret}.path;

        peers = [
          {
            publicKey = peerPublicKey;
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "${serverIP}:${toString serverPort}";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  networking.firewall.checkReversePath = "loose";
  networking.firewall.extraForwardRules = ''
    iifname "veth0" oifname "${outIface}" ip daddr ${serverIP} udp dport ${toString serverPort} accept
  '';

  systemd.services."wireguard-wg-${netnsName}" = {
    requires = ["${netnsName}-netns.service"];
    after = ["${netnsName}-netns.service"];
  };
}
