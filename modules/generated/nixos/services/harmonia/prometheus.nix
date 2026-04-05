{config, ...}: {
  services.prometheus.scrapeConfigs = [
    {
      job_name = "harmonia";
      static_configs = [{targets = ["127.0.0.1:${toString config.registry.services.harmonia.port}"];}];
    }
  ];
}
