{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.verilog.enable) {
  environment.systemPackages = with pkgs; [
    verilog
  ];
}
