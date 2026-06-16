{
  pkgs,
  config,
  lib,
  ...
}: let
  nextcloud-domain = "cloud.${config.domain}";
  service = config.services.nextcloud;
in {
  generated = {
    services.mariadb.enable = lib.mkDefault true;
    services.nginx.enable = lib.mkDefault true;
  };

  services = {
    nextcloud = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud33;
      hostName = lib.mkDefault nextcloud-domain;
      https = lib.mkDefault true;
      home = lib.mkDefault "/nextcloud";
      maxUploadSize = "32G";
      database.createLocally = true;
      extraAppsEnable = true;
      extraApps = {
        # RAW photo preview provider for the Memories/Photos timeline (NEF,
        # CR2/CR3, ARW, DNG, RW2, …). The bundled libraw `rs-fallback` binary
        # won't run on NixOS (non-FHS linker), but the embedded-JPEG extraction
        # path (via the imagick PHP module) covers normal RAW files.
        camerarawpreviews = pkgs.fetchNextcloudApp {
          url = "https://github.com/ariselseng/camerarawpreviews/releases/download/v1.1.1/camerarawpreviews_nextcloud.tar.gz";
          hash = "sha256-PWX7WPJKoMIy4Kn6IH/+6UxPQ4G/nxuDNV1nNaGMp1s=";
          license = "agpl3Plus";
        };
        # Pre-renders previews in the background so the Memories timeline loads
        # fast. New uploads are handled via the regular nextcloud-cron; run
        # `nextcloud-occ preview:generate-all` once to backfill existing files.
        previewgenerator = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/previewgenerator/releases/download/v5.13.0/previewgenerator-v5.13.0.tar.gz";
          hash = "sha256-i2Z/kOEi1e3SoNj5zs3CyDHeRTAGYpuCzH5zybDQ38A=";
          license = "agpl3Plus";
        };
        # NOTE: recognize is intentionally NOT pinned here. It installs its node
        # runtime + node_modules and downloads ~1.1GB of ML models into its own
        # app directory at runtime, which fails when nix-managed (read-only in
        # /nix/store). It must stay an appstore-installed (writable) app.
      };
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
        "memories.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.vod.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
      };
    };
    nginx = {
      # Setup Nextcloud virtual host to listen on ports
      virtualHosts = {
        "${service.hostName}" = {
          ## Force HTTP redirect to HTTPS
          forceSSL = lib.mkDefault service.https;
          ## LetsEncrypt
          enableACME = lib.mkDefault service.https;

          extraConfig = ''
            access_log  /var/log/nginx/access.log  main;

            # Strip CSP headers that break the Memories Android app timeline
            # https://github.com/pulsejet/memories/issues/1396
            fastcgi_hide_header Content-Security-Policy;
          '';
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
