{
  config,
  pkgs,
  lib,
  ...
}: {
  # Create a shared group for many services
  users.groups."shared-media" = {};

  services = {
    audiobookshelf.group = "shared-media";
    bazarr.group = "shared-media";
    jellyfin.group = "shared-media";
    radarr.group = "shared-media";
    readarr.group = "shared-media";
    sonarr.group = "shared-media";
    immich.group = "shared-media";
    calibre-web.group = "shared-media";
  };

  generated.services.media.qbittorrent.include.group = "shared-media";

  services = {
    jellyfin.enable = true;

    seerr.enable = true;

    prowlarr.enable = true;

    flaresolverr.enable = true;

    sonarr.enable = true;
    radarr.enable = true;

    bazarr.enable = true;

    readarr.enable = true;
  };

  # Suppress repetitive service logs via systemd LogFilterPatterns
  systemd.services = {
    # Radarr: ~50k/day — repeated QualityFinder warnings and ffprobe errors on broken files
    radarr.serviceConfig.LogFilterPatterns = [
      "~.*QualityFinder: Unable to find exact quality.*"
      "~.*VideoFileInfoReader: Unable to parse media info.*"
      "~.*DetectSample: Failed to get runtime.*"
      "~.*FFMpegCore.Exceptions.*"
      "~.*ffprobe exited with non-zero.*"
      "~.*EBML header parsing failed.*"
    ];

    # Seerr (formerly Jellyseerr): ~13k/day — debug-level download sync every minute
    seerr.serviceConfig.LogFilterPatterns = [
      "~.*\\[debug\\].*"
    ];

    # Jellyfin: ~3.5k/day — playback tracker polling + webhook task completion
    jellyfin.serviceConfig.LogFilterPatterns = [
      "~.*Processing playback tracker.*"
      "~.*Webhook Item .* Notifier Completed.*"
    ];

    # qbittorrent-natpmp: ~3.5k/day — logs every 45s even when nothing changes
    qbittorrent-natpmp.serviceConfig.LogFilterPatterns = [
      "~.*Requesting NAT-PMP port mapping.*"
      "~.*Mapped port:.*"
    ];
  };
}
