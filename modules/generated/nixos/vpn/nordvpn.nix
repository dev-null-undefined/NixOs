{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cf = config.generated.vpn.nordvpn;

  vpnServerIP = "87.249.135.247";
  vpnConfig = ./cz147.nordvpn.com.udp.ovpn;
  inherit (cf) outIface netnsName;
in {
  moduleSettings = {
    netnsName = lib.mkOption {
      type = lib.types.str;
      default = "nordvpn";
      description = "Network namespace name";
    };
    outIface = lib.mkOption {
      type = lib.types.str;
      default = config.generated.router.interfaces.external;
      description = "Interface use for NAT ing the namespace through.";
    };
  };

  systemd.services.nordvpn-netns = {
    description = "Set up nordvpn network namespace and firewall";
    wantedBy = ["multi-user.target"];
    before = ["nordvpn-openvpn.service"];

    path = with pkgs; [iptables iproute2 nettools coreutils];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = pkgs.writeShellScript "nordvpn-netns-stop" ''
        echo "[nordvpn-netns] Stopping..."

        # Kill any processes in netns
        ip netns pids ${netnsName} | xargs -r kill || true

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

        echo "[nordvpn-netns] Stopping Done."
      '';
      ExecStart = pkgs.writeShellScript "nordvpn-netns-start" ''
        echo "[nordvpn-netns] Starting..."

        ip netns add ${netnsName} || true

        ip link show veth0 || ip link add veth0 type veth peer name veth1
        ip link set veth1 netns ${netnsName}
        ip addr add 10.200.200.1/24 dev veth0 || true
        ip link set veth0 up

        ip netns exec ${netnsName} ip addr add 10.200.200.2/24 dev veth1 || true
        ip netns exec ${netnsName} ip link set veth1 up
        ip netns exec ${netnsName} ip link set lo up
        ip netns exec ${netnsName} ip route add default via 10.200.200.1 || true

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

        ip netns exec ${netnsName} iptables -A OUTPUT -o tun0 -j ACCEPT
        ip netns exec ${netnsName} iptables -A INPUT -i tun0 -j ACCEPT

        ip netns exec ${netnsName} iptables -A OUTPUT -o veth1 -d ${vpnServerIP} -p udp --dport 1194 -j ACCEPT

        echo "[nordvpn-netns] Setup complete."
      '';
    };
  };

  sops.secrets."nordvpn-auth.txt" = {
    sopsFile = self.outPath + "/secrets/nord-vpn.txt";
    format = "binary";
  };

  systemd.services.nordvpn-openvpn = {
    description = "Run OpenVPN inside nordvpn netns";
    requires = ["nordvpn-netns.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "notify";
      Restart = "on-failure";
      ExecStart = pkgs.writeShellScript "nordvpn-auth-wrapper" ''
        exec ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.openvpn}/sbin/openvpn \
          --config ${vpnConfig} \
          --auth-user-pass ${config.sops.secrets."nordvpn-auth.txt".path}
      '';
    };
  };
}
