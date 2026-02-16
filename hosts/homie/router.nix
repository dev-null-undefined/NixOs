{
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
        dhcp.staticLeases = {
          "uzdil-proxmox" = {
            mac = "c8:7f:54:68:43:4d";
            ip = "192.168.10.50";
          };
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
