{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cf = config.generated.vpn.confinement;

  vpnServerIP = "146.70.129.18";
  vpnPort = "51820";
  inherit (cf) outIface netnsName;

  protoList = protocol:
    if protocol == "both"
    then ["tcp" "udp"]
    else [protocol];

  # Generate nft rules for open ports inside the netns
  generateOpenPortRules = ports:
    builtins.concatStringsSep "\n" (builtins.concatMap ({
      port,
      protocol,
    }:
      builtins.map (proto: "        ${proto} dport ${toString port} accept")
      (protoList protocol))
    ports);

  openPortRules = generateOpenPortRules cf.openPorts;

  # Generate nft DNAT rules for port mappings on the host
  generateDnatRules = mappings:
    builtins.concatStringsSep "\n" (builtins.concatMap ({
      from,
      to,
      protocol,
    }:
      builtins.map (proto: "        ${proto} dport ${toString from} dnat to 10.200.200.2:${toString to}")
      (protoList protocol))
    mappings);

  dnatRules = generateDnatRules cf.portMappings;

  hostNftConf = pkgs.writeText "${netnsName}-host-nft.conf" ''
    table ip vpn-${netnsName} {
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.200.200.0/24 oifname "${outIface}" masquerade
      }
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
    ${dnatRules}
      }
    }
  '';

  netnsNftConf = pkgs.writeText "${netnsName}-netns-nft.conf" ''
    table inet filter {
      chain input {
        type filter hook input priority filter; policy drop;
        iifname "lo" accept
        ct state established,related accept
        iifname "wg-${netnsName}" accept
    ${openPortRules}
      }
      chain output {
        type filter hook output priority filter; policy drop;
        oifname "lo" accept
        ct state established,related accept
        oifname "wg-${netnsName}" accept
        oifname "veth1" ip daddr ${vpnServerIP} udp dport ${vpnPort} accept
      }
      chain forward {
        type filter hook forward priority filter; policy drop;
      }
    }
  '';
in {
  options = {
    netnsName = lib.mkOption {
      type = lib.types.str;
      default = "protonvpn";
      description = "Network namespace name";
    };
    outIface = lib.mkOption {
      type = lib.types.str;
      default = config.generated.router.external.interface;
      description = "Interface use for NAT ing the namespace through.";
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
      description = ''
        Ports that should be accessible through the netns.
      '';
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
      description = ''
        A list of port mappings from
        the host to ports in the namespace.
      '';
      example = [
        {
          from = 80;
          to = 80;
          protocol = "tcp";
        }
      ];
    };
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
        echo "[${netnsName} netns] Stopping..."

        # Clean up nftables in netns
        ip netns exec ${netnsName} nft flush ruleset || true

        # Remove namespace
        ip netns del ${netnsName} || true

        # Remove veth interfaces
        ip link delete veth0 || true

        # Remove host nftables table
        nft delete table ip vpn-${netnsName} || true

        echo "[${netnsName} netns] Stopping Done."
      '';
      ExecStart = pkgs.writeShellScript "${netnsName}-netns-start" ''
        echo "[${netnsName} netns] Starting..."

        ip netns add ${netnsName} || true

        ip link show veth0 || ip link add veth0 type veth peer name veth1
        ip link set veth1 netns ${netnsName}
        ip addr add 10.200.200.1/24 dev veth0 || true
        ip link set veth0 up

        ip netns exec ${netnsName} ip addr add 10.200.200.2/24 dev veth1 || true
        ip netns exec ${netnsName} ip link set veth1 up
        ip netns exec ${netnsName} ip link set lo up
        ip netns exec ${netnsName} ip route add default via 10.200.200.1 || true
        ip netns exec ${netnsName} ip route add 146.70.129.18/32 via 10.200.200.1 dev veth1 || true

        # Host-side NAT and port forwarding via nftables
        nft delete table ip vpn-${netnsName} 2>/dev/null || true
        nft -f ${hostNftConf}

        # Netns firewall via nftables
        ip netns exec ${netnsName} nft -f ${netnsNftConf}

        echo "[${netnsName} netns] Setup complete."
      '';
    };
  };

  environment.etc."netns/${netnsName}/resolv.conf" = {
    text = ''
      nameserver 10.2.0.1
      nameserver 1.1.1.1
    '';
    mode = "0644";
  };

  sops.secrets."protonvpn-wireguard-pk" = {
    sopsFile = self.outPath + "/secrets/protonvpn-wireguard-pk";
    format = "binary";
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      "wg-${netnsName}" = {
        socketNamespace = netnsName;
        interfaceNamespace = netnsName;
        ips = ["10.2.0.2/32"];

        listenPort = 51820;

        privateKeyFile = config.sops.secrets."protonvpn-wireguard-pk".path;

        peers = [
          {
            # CZ#44
            publicKey = "sDVKmYDevvGvpKNei9f2SDbx5FMFi6FqBmuRYG/EFg8=";
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "${vpnServerIP}:${vpnPort}";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  networking.firewall.checkReversePath = false;

  systemd.services."wireguard-wg-${netnsName}" = {
    requires = ["${netnsName}-netns.service"];
    after = ["${netnsName}-netns.service"];
  };
}
