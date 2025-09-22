{
  config,
  options,
  lib,
  ...
}: let
  targetIf = exporterName:
    lib.lists.optional
    config.services.prometheus.exporters.${exporterName}.enable {
      job_name = "self-${exporterName}";
      static_configs = [
        {
          targets = [
            "127.0.0.1:${
              toString config.services.prometheus.exporters.${exporterName}.port
            }"
          ];
        }
      ];
    };
in {
  services.prometheus = {
    enable = true;
    port = 9001;
    retentionTime = "1y";
    scrapeConfigs = lib.lists.concatMap targetIf (builtins.attrNames
      (builtins.head
        (builtins.head
          options.services.prometheus.exporters.type.getSubModules)
        .imports)
      .options);
  };
}
