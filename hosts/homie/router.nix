{
  config,
  self,
  ...
}: let
  wan = config.generated.router.external.interface;
  lan = config.generated.router.vlans.main.vlanInterface;
in {
  sops.secrets."dnsmasq-static-leases" = {
    sopsFile = self.outPath + "/secrets/dnsmasq-static-leases";
    format = "binary";
    owner = "dnsmasq";
    group = "dnsmasq";
  };

  services.dnsmasq.settings.dhcp-hostsfile = config.sops.secrets."dnsmasq-static-leases".path;

  # IPv6 — WAN address + routed /64 on LAN
  networking.interfaces.${wan}.ipv6.addresses = [
    {
      address = "2a00:c500:34:6613::2";
      prefixLength = 61;
    }
  ];
  networking.interfaces.${lan}.ipv6.addresses = [
    {
      address = "2a00:c500:234:6613::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "2a00:c500:34:6613::1";
    interface = wan;
  };
  networking.nameservers = ["2a00:c500:0:12::1" "2a00:c500:0:22::1"];

  # SLAAC — advertise the routed /64 on the main LAN
  services.radvd = {
    enable = true;
    config = ''
      interface ${lan} {
        AdvSendAdvert on;
        AdvManagedFlag off;
        AdvOtherConfigFlag off;
        prefix 2a00:c500:234:6613::/64 {
          AdvOnLink on;
          AdvAutonomous on;
        };
        RDNSS 2a00:c500:234:6613::1 {
        };
      };
    '';
  };

  # Public-exposure lockdown for services that publish to 0.0.0.0 and are reached
  # via DNAT (unifi-os-server podman container; qBittorrent WebUI in the ProtonVPN
  # netns). DNAT bypasses the INPUT firewall, so the module firewall opening is
  # turned off and access is gated here:
  #   - LAN may reach the UniFi adoption ports. Unicast inform (8080) is DNAT'd,
  #     but broadcast discovery (10001) hits the host listener via INPUT, so these
  #     need explicit LAN INPUT accepts.
  #   - every published port is dropped on the WAN interface at prerouting (before
  #     DNAT), so nothing is reachable from the public internet.
  networking.firewall.interfaces.${lan} = {
    allowedTCPPorts = [8080]; # UniFi UAP device inform
    allowedUDPPorts = [3478 10001]; # UniFi STUN + device discovery
  };

  networking.nftables.tables.wan-lockdown = {
    family = "inet";
    content = ''
      chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        iifname "${wan}" tcp dport { 8080, 11443, 9091 } drop
        iifname "${wan}" udp dport { 3478, 10001 } drop
      }
    '';
  };

  generated.router = {
    enable = true;
    vlans = {
      main = {
        interface = "enp1s0";
      };
      guest = {
        id = 500;
        interface = "enp1s0";
        static = {
          ip = "192.168.50.1";
          prefix = 24;
        };
        policy = {
          nat = true;
          isolated = true;
        };
      };
      iot = {
        id = 300;
        interface = "enp1s0";
        static = {
          ip = "192.168.30.1";
          prefix = 24;
        };
        policy = {
          nat = false;
          isolated = true;
          routerAccess = true;
        };
      };
      uzdil-proxmox = {
        id = 100;
        interface = "enp1s0";
        static = {
          ip = "192.168.10.1";
          prefix = 24;
        };
        policy = {
          nat = true;
          isolated = true;
          routerAccess = true;
        };
      };
    };
    external = {
      interface = "enp6s0";
      static = {
        ip = "94.230.159.2";
        prefix = 30;
        gateway = "94.230.159.1";
      };
    };
  };
}
