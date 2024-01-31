{
  pkgs,
  lib,
  ...
}: {
  services.opensnitch.rules = {
    systemd-timesyncd = {
      name = "systemd-timesyncd";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "simple";
        sensitive = false;
        operand = "process.path";
        data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
      };
    };
  };
}
