{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    discord discord-ptb discord-canary
    #betterdiscord-installer
  ];
}
