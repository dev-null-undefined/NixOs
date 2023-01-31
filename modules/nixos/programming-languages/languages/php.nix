{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.php.enable or false) {
  environment.systemPackages = with pkgs; [
    # php
    php
  ];
}
