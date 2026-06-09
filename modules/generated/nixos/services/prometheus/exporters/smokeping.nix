{
  # Continuous ICMP latency + loss prober. Pings each target every second and
  # exposes a response-duration histogram + request/response counters, so loss
  # and latency-under-load are visible between scrapes (port 9374, auto-scraped
  # as self-smokeping by ../server.nix). Needs CAP_NET_RAW (handled upstream).
  services.prometheus.exporters.smokeping = {
    enable = true;
    pingInterval = "1s";
    # Generic internet baselines, safe on any host. Per-host targets (e.g. a
    # WAN first hop) are appended by the host config; the option is a list so
    # definitions merge.
    hosts = [
      "1.1.1.1" # Cloudflare — internet baseline
      "8.8.8.8" # Google — internet baseline
    ];
  };
}
