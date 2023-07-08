{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Java
    jdk
    jdk8
    jdk11
    jdk17
    jprofiler
    visualvm
  ];
}
