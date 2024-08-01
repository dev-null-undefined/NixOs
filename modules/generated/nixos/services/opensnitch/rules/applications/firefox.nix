{
  pkgs,
  lib,
  ...
}: {
  services.opensnitch.rules = {
    app-firefox = {
      name = "app-firefox";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = rec {
        type = "list";
        operand = type;
        data = builtins.toJSON list;
        list = [
          {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.firefox}/lib/firefox/firefox";
          }
        ];
      };
    };
  };
}
