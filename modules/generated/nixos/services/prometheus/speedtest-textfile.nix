{pkgs, ...}: let
  # Runs an Ookla speedtest and writes the result as Prometheus metrics into the
  # node_exporter textfile dir (see exporters/node.nix). Decoupled from scrape
  # cadence via a systemd timer so a ~30s/~2GB test runs hourly, not per-scrape.
  # Ookla's JSON also reports loaded latency (RTT during the down/up phases) =
  # a per-hour bufferbloat reading alongside the continuous smokeping probe.
  speedtestWriter = pkgs.writers.writePython3 "speedtest-textfile" {flakeIgnore = ["E501"];} ''
    import json
    import os
    import subprocess
    import tempfile

    OUT_DIR = "/var/lib/node-exporter-textfile"
    OUT_FILE = os.path.join(OUT_DIR, "speedtest.prom")
    # Pin a server id here for consistency across runs; "" = auto-pick nearest.
    SERVER_ID = ""
    SPEEDTEST = "${pkgs.ookla-speedtest}/bin/speedtest"


    def run_speedtest():
        cmd = [SPEEDTEST, "--format=json", "--accept-license", "--accept-gdpr"]
        if SERVER_ID:
            cmd += ["--server-id", SERVER_ID]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
        except (subprocess.TimeoutExpired, OSError):
            return None
        if proc.returncode != 0:
            return None
        try:
            return json.loads(proc.stdout)
        except json.JSONDecodeError:
            return None


    def metric(name, help_text, value, labels=""):
        return [
            f"# HELP speedtest_{name} {help_text}",
            f"# TYPE speedtest_{name} gauge",
            f"speedtest_{name}{labels} {value}",
        ]


    def build_body(data):
        lines = []
        if data is None:
            lines += metric("up", "Speedtest succeeded (1) or failed (0)", 0)
            return "\n".join(lines) + "\n"

        dl = data.get("download", {})
        ul = data.get("upload", {})
        ping = data.get("ping", {})
        server = data.get("server", {})
        sid = server.get("id", "")
        sname = str(server.get("name", "")).replace('"', "")

        lines += metric("download_bits_per_second", "Download bandwidth (bits/s)", dl.get("bandwidth", 0) * 8)
        lines += metric("upload_bits_per_second", "Upload bandwidth (bits/s)", ul.get("bandwidth", 0) * 8)
        lines += metric("ping_latency_ms", "Idle round-trip latency (ms)", ping.get("latency", 0))
        lines += metric("jitter_ms", "Idle latency jitter (ms)", ping.get("jitter", 0))
        lines += metric("download_loaded_latency_ms", "Latency under download load (ms), bufferbloat", dl.get("latency", {}).get("iqm", 0))
        lines += metric("upload_loaded_latency_ms", "Latency under upload load (ms), bufferbloat", ul.get("latency", {}).get("iqm", 0))
        lines += metric("packet_loss_percent", "Packet loss during test (percent)", data.get("packetLoss", 0))
        lines += metric("info", "Speedtest server info", 1, f'{{server_id="{sid}",server_name="{sname}"}}')
        lines += metric("up", "Speedtest succeeded (1) or failed (0)", 1)
        return "\n".join(lines) + "\n"


    def main():
        body = build_body(run_speedtest())
        os.makedirs(OUT_DIR, exist_ok=True)
        fd, tmp = tempfile.mkstemp(dir=OUT_DIR, suffix=".tmp")
        try:
            with os.fdopen(fd, "w") as fh:
                fh.write(body)
            os.chmod(tmp, 0o644)
            os.replace(tmp, OUT_FILE)
        except Exception:
            if os.path.exists(tmp):
                os.remove(tmp)
            raise


    if __name__ == "__main__":
        main()
  '';
in {
  # World-readable dir so node_exporter (a different service user) can read the
  # .prom file the writer drops here.
  systemd.tmpfiles.rules = [
    "d /var/lib/node-exporter-textfile 0755 root root -"
  ];

  systemd.services.speedtest-textfile = {
    description = "Ookla speedtest to node_exporter textfile metrics";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${speedtestWriter}";
      TimeoutStartSec = "300";
      Environment = "HOME=/tmp"; # Ookla wants a writable HOME for its config db
      ReadWritePaths = ["/var/lib/node-exporter-textfile"];
      CapabilityBoundingSet = "";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
    };
  };

  systemd.timers.speedtest-textfile = {
    description = "Run Ookla speedtest hourly";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "5m"; # spread load off the exact top of the hour
      Persistent = true;
    };
  };
}
