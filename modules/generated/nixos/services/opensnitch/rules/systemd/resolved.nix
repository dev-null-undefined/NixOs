{
  pkgs,
  lib,
  ...
}: {
  services.opensnitch.rules = {
    systemd-resolved = {
      name = "systemd-resolved";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "simple";
        sensitive = false;
        operand = "process.path";
        data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
      };
    };
  };
}
