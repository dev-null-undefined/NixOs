{
  services.prometheus.exporters.node = {
    enable = true;
    # textfile: lets the hourly speedtest service (../speedtest-textfile.nix)
    # publish capacity/latency metrics by dropping a .prom file in the dir below.
    enabledCollectors = ["systemd" "textfile"];
    extraFlags = ["--collector.textfile.directory=/var/lib/node-exporter-textfile"];
  };
}
