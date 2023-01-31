{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.js.enable or false) {
  environment.systemPackages = with pkgs; [
    # JavaScript
    nodejs
    nodePackages.npm
    yarn
  ];
}
