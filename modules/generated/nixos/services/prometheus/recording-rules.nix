{
  services.prometheus.rules = [
    (builtins.toJSON {
      groups = [
        {
          name = "device_info";
          interval = "1m";
          rules = [
            {
              record = "device_info";
              expr = ''group by (mac, name, ip) (unpoller_client_receive_bytes_total{mac!=""})'';
              labels.source = "unpoller";
            }
          ];
        }
      ];
    })
  ];
}
