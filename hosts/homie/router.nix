{
  generated.router = {
    enable = true;
    dhcp.gateway = "192.168.2.1";
    interfaces = {
      internal = "enp1s0";
      external = "enp6s0";
    };
  };
}
