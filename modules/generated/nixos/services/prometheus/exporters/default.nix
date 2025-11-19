{
  config,
  lib,
  ...
}: {
  generated.services.prometheus.exporters = {
    dnsmasq.enable = lib.mkDefault config.services.dnsmasq.enable;
    nextcloud.enable = lib.mkDefault config.services.nextcloud.enable;
    unifi.enable = lib.mkDefault config.generated.services.unifi-docker.enable;
    nginx-status.enable = lib.mkDefault config.services.nginx.statusPage;
    smartctl.enable = lib.mkDefault config.generated.services.smartd.enable;
    node.enable = lib.mkDefault true;
  };
}
