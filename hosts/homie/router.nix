{
  config,
  self,
  ...
}: {
  sops.secrets."dnsmasq-static-leases" = {
    sopsFile = self.outPath + "/secrets/dnsmasq-static-leases";
    format = "binary";
  };

  services.dnsmasq.settings.dhcp-hostsfile = config.sops.secrets."dnsmasq-static-leases".path;

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
