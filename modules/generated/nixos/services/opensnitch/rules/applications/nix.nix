{
  config,
  lib,
  ...
}: {
  services.opensnitch.rules = {
    app-nix = {
      name = "app-nix";
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
            data = "${lib.getBin config.nix.package}/bin/nix";
          }
        ];
      };
    };
  };
}
