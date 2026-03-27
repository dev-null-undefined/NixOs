{config, ...}: {
  services.tailscale.enable = true;

  networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];

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
