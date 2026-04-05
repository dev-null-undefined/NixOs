{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  routerCfg = config.generated.router;
  vlanIPs = lib.mapAttrsToList (_: v: v.static.ip) routerCfg.vlans;

  exporterScript = pkgs.writers.writePython3 "adguard-exporter" {} ''
    import json
    import urllib.error
    import urllib.request
    import http.server
    import base64
    import os
    from collections import Counter, defaultdict

    AGH_URL = "http://127.0.0.1:${toString config.registry.services.adguard.port}"
    LEASE_FILE = "/var/lib/dnsmasq/dnsmasq.leases"
    PORT = ${toString config.registry.services."adguard-exporter".port}
    QUERYLOG_LIMIT = 2000
    TOP_N = 15


    def load_ip_to_mac():
        mapping = {}
        try:
            with open(LEASE_FILE) as f:
                for line in f:
                    parts = line.strip().split()
                    if len(parts) >= 3:
                        mac = parts[1].lower()
                        ip = parts[2]
                        mapping[ip] = mac
        except FileNotFoundError:
            pass
        return mapping


    def agh_api(path):
        creds = os.environ.get("AGH_CREDS", "admin:")
        auth = base64.b64encode(creds.encode()).decode()
        req = urllib.request.Request(
            f"{AGH_URL}{path}",
            headers={"Authorization": f"Basic {auth}"},
        )
        try:
            with urllib.request.urlopen(req, timeout=10) as r:
                return json.loads(r.read())
        except (urllib.error.URLError, json.JSONDecodeError, OSError):
            return None


    def esc(s):
        return s.replace("\\", "\\\\").replace('"', '\\"')


    def gauge(lines, name, help_text, value):
        lines.append(f"# HELP {name} {help_text}")
        lines.append(f"# TYPE {name} gauge")
        lines.append(f"{name} {value}")


    def gauge_map(lines, name, help_text, entries,
                  label="domain", limit=20,
                  ip_to_mac=None):
        lines.append(f"# HELP {name} {help_text}")
        lines.append(f"# TYPE {name} gauge")
        for entry in entries[:limit]:
            for k, v in entry.items():
                mac = ""
                if ip_to_mac and k in ip_to_mac:
                    mac = f',mac="{ip_to_mac[k]}"'
                lines.append(
                    f'{name}{{{label}="{esc(k)}"{mac}}} {v}'
                )


    def gauge_counter(lines, name, help_text,
                      counter, label, limit=TOP_N,
                      ip_to_mac=None):
        lines.append(f"# HELP {name} {help_text}")
        lines.append(f"# TYPE {name} gauge")
        for k, v in counter.most_common(limit):
            mac = ""
            if ip_to_mac and k in ip_to_mac:
                mac = f',mac="{ip_to_mac[k]}"'
            lines.append(
                f'{name}{{{label}="{esc(k)}"{mac}}} {v}'
            )


    def gauge_nested(lines, name, help_text,
                     outer, inner_map,
                     outer_label, inner_label,
                     limit=TOP_N, ip_to_mac=None):
        lines.append(f"# HELP {name} {help_text}")
        lines.append(f"# TYPE {name} gauge")
        for key, _ in outer.most_common(limit):
            mac = ""
            if ip_to_mac and key in ip_to_mac:
                mac = f',mac="{ip_to_mac[key]}"'
            for k, v in inner_map[key].most_common(limit):
                lines.append(
                    f"{name}"
                    f'{{{outer_label}="{esc(key)}"{mac},'
                    f'{inner_label}="{esc(k)}"}} {v}'
                )


    def emit_stats(lines, stats, ip_to_mac):
        total = stats.get("num_dns_queries", 0)
        blocked = stats.get("num_blocked_filtering", 0)
        pct = (blocked / total * 100) if total > 0 else 0

        gauge(lines, "adguard_dns_queries_total",
              "Total DNS queries", total)
        gauge(lines, "adguard_blocked_total",
              "Blocked queries", blocked)
        gauge(lines, "adguard_blocked_percentage",
              "Blocked percentage", f"{pct:.2f}")
        gauge(lines, "adguard_avg_processing_time_seconds",
              "Average DNS processing time",
              stats.get("avg_processing_time", 0))

        gauge_map(lines, "adguard_top_queried_domain",
                  "Top queried domains",
                  stats.get("top_queried_domains", []))
        gauge_map(lines, "adguard_top_blocked_domain",
                  "Top blocked domains",
                  stats.get("top_blocked_domains", []))
        gauge_map(lines, "adguard_top_client",
                  "Top clients",
                  stats.get("top_clients", []),
                  label="client",
                  ip_to_mac=ip_to_mac)
        gauge_map(lines, "adguard_upstream_responses",
                  "Responses per upstream",
                  stats.get("top_upstreams_responses", []),
                  label="upstream")
        gauge_map(lines, "adguard_upstream_avg_time_seconds",
                  "Average upstream response time",
                  stats.get("top_upstreams_avg_time", []),
                  label="upstream")


    def emit_querylog(lines, ip_to_mac):
        ql = agh_api(
            f"/control/querylog?limit={QUERYLOG_LIMIT}"
            "&response_status=all"
        )
        if not ql:
            return

        client_queries = Counter()
        client_blocked = Counter()
        client_domains = defaultdict(Counter)
        client_blocked_domains = defaultdict(Counter)

        for e in ql.get("data", []):
            c = e.get("client", "?")
            d = e.get("question", {}).get("name", "?")
            d = d.rstrip(".")
            reason = e.get("reason", "")

            client_queries[c] += 1
            client_domains[c][d] += 1

            if reason.startswith("Filtered"):
                client_blocked[c] += 1
                client_blocked_domains[c][d] += 1

        gauge_counter(
            lines, "adguard_client_queries",
            "Queries per client (recent)",
            client_queries, "client",
            ip_to_mac=ip_to_mac)
        gauge_counter(
            lines, "adguard_client_blocked",
            "Blocked per client (recent)",
            client_blocked, "client",
            ip_to_mac=ip_to_mac)
        gauge_nested(
            lines, "adguard_client_domain",
            "Top domains per client (recent)",
            client_queries, client_domains,
            "client", "domain",
            ip_to_mac=ip_to_mac)
        gauge_nested(
            lines, "adguard_client_blocked_domain",
            "Top blocked domains per client",
            client_blocked, client_blocked_domains,
            "client", "domain",
            ip_to_mac=ip_to_mac)


    def emit_status(lines):
        status = agh_api("/control/status")
        if status:
            running = 1 if status.get("running") else 0
            prot = (
                1
                if status.get("protection_enabled")
                else 0
            )
            gauge(lines, "adguard_up",
                  "AdGuard Home status", running)
            gauge(lines, "adguard_protection_enabled",
                  "Filtering protection", prot)
        else:
            gauge(lines, "adguard_up",
                  "AdGuard Home status", 0)


    class MetricsHandler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path != "/metrics":
                self.send_response(404)
                self.end_headers()
                return

            lines = []
            ip_mac = load_ip_to_mac()

            stats = agh_api("/control/stats")
            if stats:
                emit_stats(lines, stats, ip_mac)

            emit_status(lines)
            emit_querylog(lines, ip_mac)

            body = "\n".join(lines) + "\n"
            self.send_response(200)
            self.send_header(
                "Content-Type", "text/plain; version=0.0.4"
            )
            self.end_headers()
            self.wfile.write(body.encode())

        def log_message(self, format, *args):
            pass


    server = http.server.HTTPServer(
        ("127.0.0.1", PORT), MetricsHandler
    )
    server.serve_forever()
  '';
in {
  sops.secrets."adguard-admin-pass" = {
    sopsFile = self.outPath + "/secrets/adguard-admin-pass";
    format = "binary";
  };

  systemd.services.adguardhome = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "127.0.0.1";
    port = config.registry.services.adguard.port;
    settings = {
      schema_version = 29;

      users = [
        {
          name = "admin";
          password = "$2y$10$aU3b1jntuhqEjj1JKEVwKe2V2WpZCP4BUPaCzeqyyPiOVUtYat4eS";
        }
      ];

      dns = {
        bind_hosts = vlanIPs ++ ["127.0.0.1"];
        port = 53;

        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
          "1.1.1.1"
          "8.8.8.8"
        ];
        bootstrap_dns = ["1.1.1.1" "8.8.8.8"];
        fallback_dns = ["1.1.1.1" "8.8.8.8"];

        cache_size = 10000000;
        cache_ttl_min = 300;
        cache_optimistic = true;
        ratelimit = 0;
        fastest_addr = true;
      };

      filtering.enabled = true;

      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          name = "StevenBlack Unified";
          id = 2;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 3;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
          name = "Dan Pollock's List";
          id = 4;
        }
      ];

      statistics = {
        enabled = true;
        interval = "720h";
      };

      querylog = {
        enabled = true;
        interval = "720h";
        size_memory = 1000;
      };

      dhcp.enabled = false;

      clients.runtime_sources = {
        whois = true;
        arp = true;
        rdns = false;
        dhcp = false;
        hosts = true;
      };
    };
  };

  # Custom Prometheus exporter for AdGuard Home
  systemd.services.prometheus-adguard-exporter = {
    after = ["adguardhome.service"];
    description = "AdGuard Home Prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      LoadCredential = "admin-pass:${config.sops.secrets."adguard-admin-pass".path}";
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
    script = ''
      export AGH_CREDS="admin:$(cat $CREDENTIALS_DIRECTORY/admin-pass)"
      exec ${exporterScript}
    '';
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "adguard-home";
      static_configs = [{targets = ["127.0.0.1:${toString config.registry.services."adguard-exporter".port}"];}];
    }
  ];
}
