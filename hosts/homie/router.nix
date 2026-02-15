{
  generated.router = {
    enable = true;
    internal = {
      interface = "enp1s0";
      dhcpd.staticLeases = {
        "uzdil-proxmox" = {
          mac = "c8:7f:54:68:43:4d";
          ip = "192.168.1.50";
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
