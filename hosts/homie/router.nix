{
  generated.router = {
    enable = true;
    internal = {
      interface = "enp1s0";
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
