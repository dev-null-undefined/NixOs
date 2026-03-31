{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.services.prometheus-sonarr-exporter = {
    after = ["sonarr.service"];
    description = "Sonarr Prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      SupplementaryGroups = ["sonarr"];
      ExecStart = ''
        ${lib.getExe pkgs.exportarr} sonarr \
          --url http://127.0.0.1:8989 \
          --port 9709 \
          --config /var/lib/sonarr/.config/Sonarr/config.xml \
          --enable-additional-metrics
      '';
      Restart = "on-failure";
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "sonarr";
      static_configs = [{targets = ["127.0.0.1:9709"];}];
    }
  ];
}
