let
  internalInterface = "enp3s0";
  externalInterface = "enp5s0";
in {
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = internalInterface;
      dhcp-range = "192.168.2.2,192.168.2.254";
      dhcp-option = "3,192.168.2.1";
    };
  };

  networking = {
    firewall.allowPing = true;
    firewall.allowedUDPPorts = [53 67];
    firewall.allowedTCPPorts = [53];
    nat = {
      enable = true;
      inherit externalInterface;
      internalInterfaces = [internalInterface];
    };

    # networking.enableIPv6 = true;
    useDHCP = false;
    interfaces = {
      ${externalInterface}.useDHCP = true;
      ${internalInterface}.ipv4.addresses = [
        {
          address = "192.168.2.1";
          prefixLength = 24;
        }
      ];
    };
  };
}
