{
  config,
  pkgs,
  ...
}: {
  services.victorialogs = {
    enable = true;
    extraOptions = [
      "-journald.streamFields=_SYSTEMD_UNIT,_HOSTNAME"
      "-journald.includeEntryMetadata"
      "-retentionPeriod=2y"
    ];
  };

  services.journald.upload = {
    enable = true;
    settings.Upload = {
      URL = "http://127.0.0.1:${toString config.registry.services.victorialogs.port}/insert/journald";
    };
  };

  systemd.services.systemd-journal-upload = {
    after = ["victorialogs.service"];
    wants = ["victorialogs.service"];
  };

  services.grafana = {
    settings.plugins.allow_loading_unsigned_plugins = "victoriametrics-logs-datasource";
    declarativePlugins = with pkgs.grafanaPlugins; [
      victoriametrics-logs-datasource
    ];
  };
}
