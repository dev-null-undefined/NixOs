{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.generated.services.media.qbittorrent;
  vpnNetns = config.generated.vpn.confinement.netnsName;
  vpnGateway = builtins.head config.generated.vpn.confinement.vpn.dns;

  natpmpc = "${pkgs.libnatpmp}/bin/natpmpc";
  curl = "${pkgs.curl}/bin/curl";
  grep = "${pkgs.gnugrep}/bin/grep";
  awk = "${pkgs.gawk}/bin/awk";

  script = pkgs.writeShellScript "qbittorrent-natpmp" ''
    set -uo pipefail

    GATEWAY="${vpnGateway}"
    QB_HOST="localhost"
    QB_PORT="${toString cfg.include.port}"
    QB_USER="admin"
    QB_PASS="$(cat ${config.sops.secrets."qbittorrent-pass".path})"

    qbt_login() {
      SID=$(${curl} -s -i \
        --data-urlencode "username=$QB_USER" \
        --data-urlencode "password=$QB_PASS" \
        "http://$QB_HOST:$QB_PORT/api/v2/auth/login" \
        | ${grep} -i '^set-cookie:' \
        | ${awk} -F'[=;]' '{print $2}')
      echo "$SID"
    }

    qbt_set_port() {
      local port="$1"
      local sid="$2"
      ${curl} -s \
        --cookie "SID=$sid" \
        --data "json={\"listen_port\":$port}" \
        "http://$QB_HOST:$QB_PORT/api/v2/app/setPreferences"
    }

    CURRENT_PORT=""

    while true; do
      echo "$(date): Requesting NAT-PMP port mapping..."

      # Request UDP and TCP port mappings
      UDP_RESULT=$(${natpmpc} -a 1 0 udp 60 -g "$GATEWAY" 2>&1) || {
        echo "ERROR: natpmpc UDP failed: $UDP_RESULT"
        sleep 5
        continue
      }
      TCP_RESULT=$(${natpmpc} -a 1 0 tcp 60 -g "$GATEWAY" 2>&1) || {
        echo "ERROR: natpmpc TCP failed: $TCP_RESULT"
        sleep 5
        continue
      }

      # Extract the mapped public port from the UDP result
      PORT=$(echo "$UDP_RESULT" | ${grep} "Mapped public port" | ${awk} '{print $4}')

      if [ -z "$PORT" ]; then
        echo "ERROR: Could not parse port from natpmpc output"
        sleep 5
        continue
      fi

      echo "Mapped port: $PORT"

      # Update qBittorrent only if the port changed
      if [ "$PORT" != "$CURRENT_PORT" ]; then
        echo "Port changed ($CURRENT_PORT -> $PORT), updating qBittorrent..."
        SID=$(qbt_login)
        if [ -n "$SID" ]; then
          qbt_set_port "$PORT" "$SID"
          CURRENT_PORT="$PORT"
          echo "qBittorrent listen port set to $PORT"
        else
          echo "ERROR: Failed to log in to qBittorrent Web API"
        fi
      fi

      sleep 45
    done
  '';
in {
  systemd.services.qbittorrent-natpmp = {
    description = "NAT-PMP port forwarding for qBittorrent";
    after = ["qbittorrent.service"];
    requires = ["qbittorrent.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = script;
      Restart = "on-failure";
      RestartSec = 10;
      NetworkNamespacePath = "/run/netns/${vpnNetns}";
      User = cfg.include.user;
      Group = cfg.include.group;
    };
  };
}
