{
  pkgs,
  config,
  lib,
  ...
}: let
  nextcloud-domain = "cloud.${config.domain}";
  service = config.services.nextcloud;
  cfg = service.config;
in {
  generated = {
    services.mariadb.enable = lib.mkDefault true;
    services.nginx.enable = lib.mkDefault true;
  };

  services = {
    nextcloud = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud30;
      hostName = lib.mkDefault nextcloud-domain;
      https = lib.mkDefault true;
      home = lib.mkDefault "/nextcloud";
      maxUploadSize = "32G";
      config = {
        dbtype = "mysql";
        adminpassFile = "/var/nextcloud-admin-pass";
      };
      settings = {
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          # Additional
          "OC\\Preview\\HEIC"
          "OC\\Preview\\SVG"
          "OC\\Preview\\TIFF"
          "OC\\Preview\\PDF"
          "OC\\Preview\\Movie"
          "OC\\Preview\\MSOffice2003"
          "OC\\Preview\\MSOffice2007"
          "OC\\Preview\\MSOfficeDoc"
          "OC\\Preview\\Photoshop"
        ];
        "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
        "memories.vod.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
      };
    };
    mysql = {
      ensureDatabases = [cfg.dbname];
      ensureUsers = [
        {
          name = cfg.dbuser;
          ensurePermissions = {"${cfg.dbname}.*" = "ALL PRIVILEGES";};
        }
      ];
    };
    nginx = {
      # Setup Nextcloud virtual host to listen on ports
      virtualHosts = {
        "${service.hostName}" = {
          ## Force HTTP redirect to HTTPS
          forceSSL = lib.mkDefault service.https;
          ## LetsEncrypt
          enableACME = lib.mkDefault service.https;
        };
      };
    };
  };

  systemd.services.nextcloud-cron = {
    path = [
      # deps for memories app
      pkgs.perl
    ];
  };
}
