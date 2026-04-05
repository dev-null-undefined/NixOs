{
  config,
  lib,
  ...
}: {
  services.ntopng = {
    enable = true;
    httpPort = config.registry.services.ntopng.port;
  };

  services.influxdb2.enable = true;
}
