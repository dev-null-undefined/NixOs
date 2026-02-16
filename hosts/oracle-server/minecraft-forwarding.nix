{...}: {
  networking.firewall = {
    allowedTCPPorts = [25565];
    allowedUDPPorts = [33665];
  };

  networking.nftables.tables.minecraft-forwarding = {
    family = "ip";
    content = ''
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
        tcp dport 25565 dnat to 100.103.242.75:25565
        tcp dport 33665 dnat to 100.103.242.75:33665
      }
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ct status dnat masquerade
      }
    '';
  };
}
