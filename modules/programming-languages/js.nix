{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.js.enable) {
  environment.systemPackages = with pkgs; [
    # JavaScript
    nodejs
    nodePackages.npm
    yarn
  ];
}
