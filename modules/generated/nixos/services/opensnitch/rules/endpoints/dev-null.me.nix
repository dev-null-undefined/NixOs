{
  services.opensnitch.rules = {
    "dev-null.me" = {
      name = "dev-null.me";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "regexp";
        sensitive = false;
        operand = "dest.host";
        data = "^(.*\\.)?dev-null\\.me$";
      };
    };
  };
}
