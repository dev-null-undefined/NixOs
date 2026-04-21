{pkgs, ...}: {
  environment.etc."logid.cfg".text = ''
    io_timeout: 60000.0;
    devices: ({
      name: "MX Master 4";
      dpi: 1600;
      smartshift: { on: true; threshold: 15; torque: 100; };
      hiresscroll: { hires: false; invert: false; target: false; };
      thumbwheel: { divert: false; invert: false; };
    });
  '';

  systemd.services.logiops = {
    description = "Logitech Configuration Daemon";
    startLimitIntervalSec = 0;
    after = ["bluetooth.target" "graphical.target"];
    wantedBy = ["graphical.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.logiops}/bin/logid";
      User = "root";
    };
  };

  systemd.services.logiops-resume = {
    description = "Restart logiops after resume";
    after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart logiops.service";
    };
  };
}
