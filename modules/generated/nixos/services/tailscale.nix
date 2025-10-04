{config, ...}: {
  services.tailscale.enable = true;

  # Systemd service to restart Tailscale after waking up from suspend
  systemd.services.tailscale-restart-after-suspend = {
    description = "Restart Tailscale after waking up";
    after = ["suspend.target"];
    wantedBy = ["suspend.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${config.services.tailscale.package}/bin/tailscale down && sleep 0.1 && ${config.services.tailscale.package}/bin/tailscale up
      '';
      User = "root";
    };
  };
}
