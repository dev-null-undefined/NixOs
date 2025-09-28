{
  config,
  lib,
  ...
}: {
  generated.services.prometheus.exporters.nextcloud = {
    redis.enable = lib.mkDefault config.services.nextcloud.configureRedis;
    mysqld.enable = lib.mkDefault config.services.nextcloud.enable;
  };

  services.prometheus.exporters.nextcloud = {
    enable = true;
    user = "nextcloud";
    url = "https://homie.rat-python.ts.net";
    tokenFile = "/var/nextcloud-token";
  };
}
