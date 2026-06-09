{
  config,
  lib,
  ...
}: let
  cfg = config.generated.services.prometheus.recording-rules;

  # Passive throughput/drop rates for the WAN uplink, straight off node_exporter.
  # Only emitted when wanDevice is set: the interface name is a per-host fact
  # (e.g. only homie has enp6s0), and prometheus also runs on hosts that have no
  # known uplink and would otherwise record empty series for it.
  wanThroughputRules = lib.optionals (cfg.wanDevice != null) [
    {
      # [3m] window: the global scrape interval is 1m, and rate() needs
      # >=2 samples in-window, so a [1m] range yields no data. [3m] is the
      # smallest reliable window here (lower the scrape interval for finer
      # throughput resolution if desired).
      record = "wan:throughput_up_bps";
      expr = ''rate(node_network_transmit_bytes_total{device="${cfg.wanDevice}"}[3m]) * 8'';
    }
    {
      record = "wan:throughput_down_bps";
      expr = ''rate(node_network_receive_bytes_total{device="${cfg.wanDevice}"}[3m]) * 8'';
    }
    {
      record = "wan:transmit_drop_rate";
      expr = ''rate(node_network_transmit_drop_total{device="${cfg.wanDevice}"}[5m])'';
    }
    {
      record = "wan:receive_drop_rate";
      expr = ''rate(node_network_receive_drop_total{device="${cfg.wanDevice}"}[5m])'';
    }
  ];

  # Latency percentiles off the smokeping prober's response-duration histogram
  # (per-target `host` label). p50/p90/p95/p99.
  wanLatencyRules = map (q: {
    record = "wan:latency_p${toString q}";
    expr = ''histogram_quantile(0.${toString q}, sum by (host, le) (rate(smokeping_response_duration_seconds_bucket[5m])))'';
  }) [50 90 95 99];
in {
  options.wanDevice = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "enp6s0";
    description = ''
      WAN uplink interface for the wan:throughput_*/drop recording rules. Null
      (the default) omits those NIC-specific rules, so hosts without a known
      uplink don't record empty series for an interface they don't have.
    '';
  };

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
        {
          # WAN health: throughput/drops from node_exporter (per-host NIC, see
          # wanDevice), latency/loss from the smokeping prober. See
          # exporters/smokeping.nix.
          name = "network_health";
          interval = "30s";
          rules =
            wanThroughputRules
            ++ wanLatencyRules
            ++ [
              {
                # Worst-tail visibility: fraction of pings exceeding a latency the
                # p95-over-5m would smooth away. Thresholds = real histogram bucket
                # edges (0.1024s ~ 100ms; 0.8192s ~ 800ms, catches the multi-second
                # League spikes). frac_over_100ms = "how often it gets laggy".
                record = "wan:latency_frac_over_100ms";
                expr = ''clamp_min(1 - (sum by (host) (rate(smokeping_response_duration_seconds_bucket{le="0.1024"}[5m])) / sum by (host) (rate(smokeping_response_duration_seconds_count[5m]))), 0)'';
              }
              {
                record = "wan:latency_frac_over_800ms";
                expr = ''clamp_min(1 - (sum by (host) (rate(smokeping_response_duration_seconds_bucket{le="0.8192"}[5m])) / sum by (host) (rate(smokeping_response_duration_seconds_count[5m]))), 0)'';
              }
              {
                record = "wan:packet_loss_ratio";
                expr = ''clamp_min(1 - (sum by (host) (rate(smokeping_response_duration_seconds_count[5m])) / sum by (host) (rate(smokeping_requests_total[5m]))), 0)'';
              }
            ];
        }
      ];
    })
  ];
}
