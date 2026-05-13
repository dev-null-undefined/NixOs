{
  config,
  lib,
  ...
}: {
  generated.services.prometheus.exporters = {
    nextcloud.enable = lib.mkDefault config.services.nextcloud.enable;
    unifi.enable = lib.mkDefault config.generated.services.unifi.enable;
    nginx-status.enable = lib.mkDefault config.services.nginx.statusPage;
    smartctl.enable = lib.mkDefault config.generated.services.smartd.enable;
    node.enable = lib.mkDefault true;
  };

  generated.services.harmonia.prometheus.enable = lib.mkDefault config.services.harmonia.cache.enable;
}
