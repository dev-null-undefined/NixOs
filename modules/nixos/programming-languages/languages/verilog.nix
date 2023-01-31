{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.verilog.enable or false) {
  environment.systemPackages = with pkgs; [
    verilog
  ];
}
