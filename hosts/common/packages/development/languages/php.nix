{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.php.enable) {
  environment.systemPackages = with pkgs; [
    # php
    php
  ];
}
