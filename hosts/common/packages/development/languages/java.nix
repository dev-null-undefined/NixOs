{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Java
    jdk
    jdk8
    jdk11
    jprofiler
    visualvm
  ];
}
