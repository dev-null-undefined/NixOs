{
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "168h"; # 1 week max ban
      factor = "4";
    };
    jails.sshd = {
      settings = {
        enabled = true;
        port = "22,8022";
        filter = "sshd[mode=aggressive]";
      };
    };
  };

  # Disable per-packet "refused connection" logging — port scans generate ~25k entries/day
  networking.firewall.logRefusedConnections = false;

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

    # Jellyseerr: ~13k/day — debug-level download sync every minute
    jellyseerr.serviceConfig.LogFilterPatterns = [
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
