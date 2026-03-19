{lib, ...}: {
  services.ntopng = {
    enable = true;
    httpPort = 3001;
  };

  services.influxdb2.enable = true;
}
