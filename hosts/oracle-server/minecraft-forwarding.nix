{...}: {
  networking.firewall = {
    allowedTCPPorts = [25565];
    allowedUDPPorts = [33665];
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 25565 -j DNAT --to-destination 100.103.242.75:25565
      iptables -t nat -A PREROUTING -p tcp --dport 33665 -j DNAT --to-destination 100.103.242.75:33665
      iptables -t nat -A POSTROUTING -j MASQUERADE
    '';
  };
}
