{
  services.opensnitch.rules = {
    "000-allow-localhost" = {
      name = "000-allow-localhost";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "regexp";
        sensitive = false;
        operand = "dest.ip";
        data = "^(127\\.0\\.0\\.1|::1|127\\.0\\.0\\.53|ff02::1:3)$";
      };
    };
  };
}
