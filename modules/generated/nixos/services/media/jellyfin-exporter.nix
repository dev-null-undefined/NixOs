{
  config,
  pkgs,
  self,
  ...
}: let
  exporterScript = pkgs.writers.writePython3 "jellyfin-exporter" {} ''
    import json
    import urllib.request
    import http.server
    import os

    JF_URL = "http://127.0.0.1:${toString config.registry.services.jellyfin.port}"
    PORT = ${toString config.registry.services."jellyfin-exporter".port}


    def jf_api(path):
        api_key = os.environ.get("JF_API_KEY", "")
        url = f"{JF_URL}{path}?api_key={api_key}"
        try:
            with urllib.request.urlopen(url, timeout=5) as r:
                return json.loads(r.read())
        except Exception:
            return None


    class MetricsHandler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path != "/metrics":
                self.send_response(404)
                self.end_headers()
                return

            lines = []

            counts = jf_api("/Items/Counts")
            if counts:
                lines.append("# HELP jellyfin_library_items Total items by type")
                lines.append("# TYPE jellyfin_library_items gauge")
                for k, v in counts.items():
                    lines.append(f'jellyfin_library_items{{type="{k}"}} {v}')

            sessions = jf_api("/Sessions")
            if sessions is not None:
                active = len(sessions)
                playing = sum(1 for s in sessions if s.get("NowPlayingItem"))
                transcoding = sum(
                    1
                    for s in sessions
                    if s.get("PlayState", {}).get("PlayMethod") == "Transcode"
                )
                lines.append(
                    "# HELP jellyfin_active_sessions Number of active sessions"
                )
                lines.append("# TYPE jellyfin_active_sessions gauge")
                lines.append(f"jellyfin_active_sessions {active}")
                lines.append(
                    "# HELP jellyfin_playing_sessions Sessions currently playing"
                )
                lines.append("# TYPE jellyfin_playing_sessions gauge")
                lines.append(f"jellyfin_playing_sessions {playing}")
                lines.append(
                    "# HELP jellyfin_transcoding_sessions Sessions transcoding"
                )
                lines.append("# TYPE jellyfin_transcoding_sessions gauge")
                lines.append(f"jellyfin_transcoding_sessions {transcoding}")

            info = jf_api("/System/Info")
            if info:
                version = info.get("Version", "")
                lines.append("# HELP jellyfin_info Jellyfin server info")
                lines.append("# TYPE jellyfin_info gauge")
                lines.append(f'jellyfin_info{{version="{version}"}} 1')
                lines.append("# HELP jellyfin_up Jellyfin server status")
                lines.append("# TYPE jellyfin_up gauge")
                lines.append("jellyfin_up 1")
            else:
                lines.append("# HELP jellyfin_up Jellyfin server status")
                lines.append("# TYPE jellyfin_up gauge")
                lines.append("jellyfin_up 0")

            body = "\n".join(lines) + "\n"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4")
            self.end_headers()
            self.wfile.write(body.encode())

        def log_message(self, format, *args):
            pass


    server = http.server.HTTPServer(("127.0.0.1", PORT), MetricsHandler)
    server.serve_forever()
  '';
in {
  sops.secrets."jellyfin-api-key" = {
    sopsFile = self.outPath + "/secrets/jellyfin-api-key";
    format = "binary";
  };

  systemd.services.prometheus-jellyfin-exporter = {
    after = ["jellyfin.service"];
    description = "Jellyfin Prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      LoadCredential = "api-key:${config.sops.secrets."jellyfin-api-key".path}";
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
      export JF_API_KEY="$(cat $CREDENTIALS_DIRECTORY/api-key)"
      exec ${exporterScript}
    '';
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "jellyfin";
      static_configs = [{targets = ["127.0.0.1:${toString config.registry.services."jellyfin-exporter".port}"];}];
    }
  ];
}
