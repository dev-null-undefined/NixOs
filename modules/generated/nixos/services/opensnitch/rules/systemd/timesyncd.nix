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
      operator = rec {
        type = "list";
        operand = "list";
        data = builtins.toJSON list;
        list = [
          {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
          }
          {
            type = "regexp";
            operand = "dest.host";
            sensitive = false;
            data = "^.*\\.nixos\\.pool\\.ntp\\.org$";
          }
          {
            type = "simple";
            operand = "dest.port";
            sensitive = false;
            data = "123";
          }
        ];
      };
    };
  };
}
