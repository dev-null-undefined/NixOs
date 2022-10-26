{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (master.discord.override { nss = nss_latest; })
    discord-ptb
    discord-canary
    #betterdiscord-installer
  ];
}
