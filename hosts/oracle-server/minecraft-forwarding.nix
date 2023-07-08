{...}: {
  networking.firewall = {
    allowedTCPPorts = [25565];
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 25565 -j DNAT --to-destination 135.125.16.193:25600
      iptables -t nat -A POSTROUTING -j MASQUERADE
    '';
  };
}
