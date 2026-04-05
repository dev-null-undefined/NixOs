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
}
