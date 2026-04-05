{config, ...}: let
  r = config.registry;
  mcHost = r.hosts.${r.services.minecraft.host}.tailscaleIp;
  mcPort = toString r.services.minecraft.port;
  voicePort = toString r.services.minecraft-voice.port;
in {
  networking.firewall = {
    allowedTCPPorts = [r.services.minecraft.port];
    allowedUDPPorts = [r.services.minecraft-voice.port];
  };

  networking.nftables.tables.minecraft-forwarding = {
    family = "ip";
    content = ''
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
        tcp dport ${mcPort} dnat to ${mcHost}:${mcPort}
        udp dport ${voicePort} dnat to ${mcHost}:${voicePort}
      }
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ct status dnat masquerade
      }
    '';
  };
}
