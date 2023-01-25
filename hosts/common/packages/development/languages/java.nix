{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.java.enable) {
  environment.systemPackages = with pkgs; [
    # Java
    jdk
    jdk8
    jdk11
    jprofiler
    visualvm
  ];
}
