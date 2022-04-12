{ pkgs, ... }:

{

  environment.systemPackages = with pkgs.dev-null.jetbrains; [
    idea-ultimate
    phpstorm
    pycharm-professional
    webstorm
    clion
    rider
    datagrip
    #gateway

    jdk
  ];
}
