{
  generated.router = {
    enable = true;
    internal = {
      interface = "enp1s0";
    };

    external = {
      interface = "enp6s0";
      static = {
        ip = "10.52.102.19";
        prefix = 29;
        gateway = "10.52.102.17";
      };
    };
  };
}
