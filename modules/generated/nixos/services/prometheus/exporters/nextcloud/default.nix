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
    url = "https://${config.registry.services.nextcloud.host}.${config.registry.tailnetDomain}";
    tokenFile = "/var/nextcloud-token";
  };
}
