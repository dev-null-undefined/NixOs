{config, ...}: let
  internalInterface = "enp1s0";
  externalInterface = "enp6s0";
in {
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = internalInterface;
      dhcp-range = "192.168.2.2,192.168.2.254";
      dhcp-option = ["3,192.168.2.1" "6,192.168.2.1"];
      server = config.networking.nameservers;
    };
  };

  networking = {
    firewall = {
      allowPing = true;
      allowedUDPPorts = [53 67];
      allowedTCPPorts = [53];
    };
    nat = {
      enable = true;
      inherit externalInterface;
      internalInterfaces = [internalInterface];
    };

    nameservers = ["1.1.1.1" "8.8.8.8"];

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
