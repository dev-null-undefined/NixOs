{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.services.prometheus-radarr-exporter = {
    after = ["radarr.service"];
    description = "Radarr Prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      SupplementaryGroups = ["radarr"];
      ExecStart = ''
        ${lib.getExe pkgs.exportarr} radarr \
          --url http://127.0.0.1:7878 \
          --port 9710 \
          --config /var/lib/radarr/.config/Radarr/config.xml \
          --enable-additional-metrics
      '';
      Restart = "on-failure";
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "radarr";
      static_configs = [{targets = ["127.0.0.1:9710"];}];
    }
  ];
}
