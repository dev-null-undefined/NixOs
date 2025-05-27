{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.generated.services.media.qbittorrent;
in {
  options = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 9999;
      description = "Port on which the Prometheus exporter runs.";
    };
  };

  systemd.services.prometheus-qbittorrent-exporter = {
    after = ["qbittorrent.service"];
    description = "qBittorrent Prometheus exporter";
    wantedBy = ["multi-user.target"];
    environment = {
      EXPORT_METRICS_BY_TORRENT = "True";
      QBITTORRENT_USER = "admin";
      QBITTORRENT_HOST = "10.200.200.2";
      QBITTORRENT_PORT = toString cfg.include.port;
      EXPORTER_ADDRESS = "127.0.0.1";
      EXPORTER_PORT = toString cfg.prometheus.port;
    };
    serviceConfig = {
      User = cfg.include.user;
      Group = cfg.include.group;
    };
    script = ''
      export QBITTORRENT_PASS="$(cat ${
        config.sops.secrets."qbittorrent-pass".path
      })"
      ${lib.getExe pkgs.prometheus-qbittorrent-exporter}
    '';
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "qbittorrent";
      static_configs = [{targets = ["127.0.0.1:${toString cfg.prometheus.port}"];}];
    }
  ];
}
