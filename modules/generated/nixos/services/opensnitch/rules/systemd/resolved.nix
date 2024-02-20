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
      operator = rec {
        type = "list";
        operand = "list";
        data = builtins.toJSON list;
        list = [
          {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
          }
          {
            type = "regexp";
            operand = "dest.ip";
            sensitive = false;
            data = "^(1\\.1\\.1\\.1|1\\.0\\.0\\.1)$";
          }
          {
            type = "simple";
            operand = "dest.port";
            sensitive = false;
            data = "853";
          }
        ];
      };
    };
  };
}
