{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.shell.enable or false) {
  environment.systemPackages = with pkgs; [
    shfmt
  ];
}
