{
  config,
  pkgs,
  self,
  ...
}: let
  port = 9091;

  vpnNetns = config.generated.vpn.confinement.netnsName;
in {
  generated.vpn.confinement = {
    portMappings = [
      {
        from = port;
        to = port;
        protocol = "tcp";
      }
    ];
  };

  # Setup transmission
  services.transmission = {
    enable = true;
    settings = {
      port-forwarding-enabled = false;
      rpc-authentication-required = true;
      rpc-port = port;
      rpc-bind-address = "0.0.0.0";
      rpc-username = "admin";

      download-dir = "/var/data/downloads";
      # This is a salted hash of the real password
      # https://github.com/tomwijnroks/transmission-pwgen
      rpc-password = "{51475e881d2ddc772ebb0843eb9a42b4af7c49726pyJCFa6";
      # rpc-host-whitelist = hostnames.transmission; Reverse proxy stuff

      rpc-host-whitelist-enabled = false;
      # rpc-whitelist = lib.mkDefault "127.0.0.1"; # Overwritten by Cloudflare
      rpc-whitelist-enabled = false;
    };
  };

  sops.secrets."transmission-auth" = {
    sopsFile = self.outPath + "/secrets/transmission-auth";
    format = "binary";
  };

  systemd.services."transmission-port-forwarding" = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      set -u

      renew_port() {
        protocol="$1"
        port_file="$HOME/.local/state/transmission-$protocol-port"

        result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 "$protocol" 60 -g 10.2.0.1)"
        echo "$result"

        new_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol ... to local port 0 lifetime 60')"
        old_port="$(cat "$port_file")"
        echo "Mapped new $protocol port $new_port, old one was $old_port."
        echo "$new_port" >"$port_file"

        TRANSMISSION_AUTH="$(cat ${config.sops.secrets."transmission-auth".path})"

        if [ "$protocol" = tcp ]
        then
          echo "Telling transmission to listen on peer port $new_port."
          ${pkgs.transmission}/bin/transmission-remote --port "$new_port" --auth "$TRANSMISSION_AUTH"
        fi

        if [ "$new_port" -eq "$old_port" ]
        then
          echo "New $protocol port $new_port is the same as old port $old_port."
        else
          echo "Old $protocol port $old_port, new is $new_port."
        fi
      }

      renew_port udp
      renew_port tcp
    '';

    requires = ["${vpnNetns}-netns.service"];
    after = ["${vpnNetns}-netns.service"];
    serviceConfig = {NetworkNamespacePath = "/run/netns/${vpnNetns}";};
  };

  systemd.timers."transmission-port-forwarding" = {
    description = "Run transmission-port-forwarding.service every minute";
    wantedBy = ["timers.target"];
    timerConfig = {
      # Run 1 minute after boot…
      OnBootSec = "1min";
      # …and then every 1 minute thereafter
      OnUnitActiveSec = "1min";
      Persistent = true;
    };
  };

  systemd.services.transmission = {
    requires = ["${vpnNetns}-netns.service"];
    after = ["${vpnNetns}-netns.service"];
    serviceConfig = {NetworkNamespacePath = "/run/netns/${vpnNetns}";};
  };
}
