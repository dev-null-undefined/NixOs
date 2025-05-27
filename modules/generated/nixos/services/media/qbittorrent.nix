{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.generated.services.media.qbittorrent;

  vpnNetns = config.generated.vpn.confinement.netnsName;
in {
  options = {
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/qbittorrent";
      description = lib.mdDoc ''
        The directory where qBittorrent stores its data files.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
      description = lib.mdDoc ''
        User account under which qBittorrent runs.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
      description = lib.mdDoc ''
        Group under which qBittorrent runs.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9091;
      description = lib.mdDoc ''
        qBittorrent web UI port.
      '';
    };
  };

  systemd.services.qbittorrent = {
    description = "qBittorrent-nox service";
    documentation = ["man:qbittorrent-nox(1)"];
    after = ["network.target" "${vpnNetns}-netns.service"];
    requires = ["${vpnNetns}-netns.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = cfg.user;
      Group = cfg.group;

      ExecStartPre = let
        preStartScript = pkgs.writeScript "qbittorrent-run-prestart" ''
          #!${pkgs.bash}/bin/bash

          # Create data directory if it doesn't exist
          if ! test -d "$QBT_PROFILE"; then
            echo "Creating initial qBittorrent data directory in: $QBT_PROFILE"
            install -d -m 0755 -o "${cfg.user}" -g "${cfg.group}" "$QBT_PROFILE"
          fi
        '';
      in "!${preStartScript}";

      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";

      NetworkNamespacePath = "/run/netns/${vpnNetns}";
    };

    environment = {
      QBT_PROFILE = cfg.dataDir;
      QBT_WEBUI_PORT = toString cfg.port;
    };
  };

  users.users = lib.mkIf (cfg.user == "qbittorrent") {
    qbittorrent = {
      inherit (cfg) group;
      isSystemUser = true;
    };
  };

  users.groups = lib.mkIf (cfg.group == "qbittorrent") {qbittorrent = {};};

  generated.vpn.confinement = {
    portMappings = [
      {
        from = cfg.port;
        to = cfg.port;
        protocol = "tcp";
      }
    ];
  };
}
