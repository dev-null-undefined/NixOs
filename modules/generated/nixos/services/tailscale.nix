{config, ...}: {
  services.tailscale.enable = true;

  # Systemd service to restart Tailscale around suspend
  systemd.services.tailscale-restart-after-suspend = {
    description = "Restart Tailscale service";
    after = ["suspend.target"];
    wantedBy = ["suspend.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/systemctl restart tailscaled.service";
      User = "root";
    };
  };
}
