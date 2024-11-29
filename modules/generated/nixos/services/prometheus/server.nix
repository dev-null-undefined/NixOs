{
  config,
  options,
  lib,
  ...
}: let
  targetIf = exporterName:
    lib.lists.optional
    config.services.prometheus.exporters.${exporterName}.enable "127.0.0.1:${
      toString config.services.prometheus.exporters.${exporterName}.port
    }";
in {
  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "self";
        static_configs = [
          {
            targets =
              lib.lists.concatMap targetIf
              # ["node" "redis" "dnsmasq" "mysqld"];
              (builtins.attrNames
                (builtins.head
                  (builtins.head
                    options.services.prometheus.exporters.type.getSubModules)
                  .imports)
                .options);
          }
        ];
      }
    ];
  };
}
