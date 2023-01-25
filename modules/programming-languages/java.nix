{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.java.enable or false) {
  environment.systemPackages = with pkgs; [
    # Java
    jdk
    jdk8
    jdk11
    jprofiler
    visualvm
  ];
}
