{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  sops.secrets."radarr-api-key" = {
    sopsFile = self.outPath + "/secrets/radarr-api-key";
    format = "binary";
  };

  systemd.services.prometheus-radarr-exporter = {
    after = ["radarr.service"];
    description = "Radarr Prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      LoadCredential = "api-key:${config.sops.secrets."radarr-api-key".path}";
      ExecStart = ''
        ${lib.getExe pkgs.exportarr} radarr \
          --url http://127.0.0.1:${toString config.registry.services.radarr.port} \
          --port ${toString config.registry.services."radarr-exporter".port} \
          --api-key-file %d/api-key \
          --enable-additional-metrics
      '';
      Restart = "on-failure";
      ProtectHome = true;
      ProtectSystem = "strict";
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      PrivateMounts = true;
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "radarr";
      static_configs = [{targets = ["127.0.0.1:${toString config.registry.services."radarr-exporter".port}"];}];
    }
  ];
}
