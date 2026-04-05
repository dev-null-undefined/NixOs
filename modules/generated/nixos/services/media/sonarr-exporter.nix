{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  sops.secrets."sonarr-api-key" = {
    sopsFile = self.outPath + "/secrets/sonarr-api-key";
    format = "binary";
  };

  systemd.services.prometheus-sonarr-exporter = {
    after = ["sonarr.service"];
    description = "Sonarr Prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      LoadCredential = "api-key:${config.sops.secrets."sonarr-api-key".path}";
      ExecStart = ''
        ${lib.getExe pkgs.exportarr} sonarr \
          --url http://127.0.0.1:${toString config.registry.services.sonarr.port} \
          --port ${toString config.registry.services."sonarr-exporter".port} \
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
      job_name = "sonarr";
      static_configs = [{targets = ["127.0.0.1:${toString config.registry.services."sonarr-exporter".port}"];}];
    }
  ];
}
