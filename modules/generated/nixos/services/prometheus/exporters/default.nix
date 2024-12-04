{
  config,
  lib,
  ...
}: {
  generated.services.prometheus.exporters = {
    dnsmasq.enable = lib.mkDefault config.services.dnsmasq.enable;
    redis-nextcloud.enable =
      lib.mkDefault config.services.nextcloud.configureRedis;
    mysqld-nextcloud.enable = lib.mkDefault config.services.nextcloud.enable;
    nextcloud.enable = lib.mkDefault config.services.nextcloud.enable;
    unifi.enable = lib.mkDefault config.generated.services.unifi-docker.enable;
    nginx-status.enable = lib.mkDefault config.services.nginx.statusPage;

    node.enable = lib.mkDefault true;
  };
}
