{ pkgs, ... }:

{

  environment.systemPackages = with pkgs.jetbrains; [
    idea-ultimate
    phpstorm
    pycharm-professional
    webstorm
    clion
    rider
    #gateway

    jdk
  ];
}
