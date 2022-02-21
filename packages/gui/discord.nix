{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    master.discord
    discord-ptb
    discord-canary
    #betterdiscord-installer
  ];
}
