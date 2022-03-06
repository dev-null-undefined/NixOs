{ pkgs, ... }:

{

  environment.systemPackages = with pkgs.master.jetbrains; [
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
