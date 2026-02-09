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

  generateOpenPortCmd = {
    port,
    protocol,
  }:
    builtins.concatStringsSep "\n" (builtins.map (proto: ''
        ip netns exec ${netnsName} iptables \
        -A INPUT -p ${proto} \
        --dport ${toString port} \
        -j ACCEPT
      '') (
        if protocol == "both"
        then ["tcp" "udp"]
        else [protocol]
      ));

  generateOpenPorts = ports:
    builtins.concatStringsSep "\n" (builtins.map generateOpenPortCmd ports);

  openPortsCmd = generateOpenPorts cf.openPorts;

  generatePortMappingCmd = {
    from,
    to,
    protocol,
  }:
    builtins.concatStringsSep "\n" (builtins.map (proto: ''
        iptables -t nat -A PREROUTING -p ${proto} \
        --dport ${toString from} \
        -j DNAT \
        --to-destination 10.200.200.2:${toString to}
      '') (
        if protocol == "both"
        then ["tcp" "udp"]
        else [protocol]
      ));

  generatePortMapping = mappings:
    builtins.concatStringsSep "\n"
    (builtins.map generatePortMappingCmd mappings);

  mappingCmds = generatePortMapping cf.portMappings;
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

    path = with pkgs; [iptables iproute2 nettools coreutils];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = pkgs.writeShellScript "${netnsName}-netns-stop" ''
        echo "[${netnsName} netns] Stopping..."

        # Clean up iptables in netns
        ip netns exec ${netnsName} iptables -F || true
        ip netns exec ${netnsName} iptables -P INPUT ACCEPT || true
        ip netns exec ${netnsName} iptables -P OUTPUT ACCEPT || true
        ip netns exec ${netnsName} iptables -P FORWARD ACCEPT || true

        # Remove namespace
        ip netns del ${netnsName} || true

        # Remove veth interfaces
        ip link delete veth0 || true

        # Remove host iptables NAT rule
        iptables -t nat -D POSTROUTING -s 10.200.200.0/24 -o ${outIface} -j MASQUERADE 2>/dev/null || true

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


        iptables -t nat -C POSTROUTING -s 10.200.200.0/24 -o ${outIface} -j MASQUERADE 2>/dev/null || \
          iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o ${outIface} -j MASQUERADE

        ip netns exec ${netnsName} iptables -F
        ip netns exec ${netnsName} iptables -P OUTPUT DROP
        ip netns exec ${netnsName} iptables -P INPUT DROP
        ip netns exec ${netnsName} iptables -P FORWARD DROP
        ip netns exec ${netnsName} iptables -A INPUT -i lo -j ACCEPT
        ip netns exec ${netnsName} iptables -A OUTPUT -o lo -j ACCEPT

        ip netns exec ${netnsName} iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        ip netns exec ${netnsName} iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        ip netns exec ${netnsName} iptables -A OUTPUT -o wg-${netnsName} -j ACCEPT
        ip netns exec ${netnsName} iptables -A INPUT -i wg-${netnsName} -j ACCEPT

        ip netns exec ${netnsName} iptables -A OUTPUT -o veth1 -d ${vpnServerIP} -p udp --dport ${vpnPort} -j ACCEPT

        # Open ports
        ${openPortsCmd}

        # Port mappings
        ${mappingCmds}

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
