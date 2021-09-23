{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
      (pkgs.discord.overrideAttrs (old: rec{
        version = "0.0.16";
        src = fetchurl {
          url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          sha256 = "1s9qym58cjm8m8kg3zywvwai2i3adiq6sdayygk2zv72ry74ldai";
        };
      }))
      (pkgs.discord-ptb.overrideAttrs (old :rec{
         version = "0.0.26";
         src = fetchurl {
          url = "https://dl-ptb.discordapp.net/apps/linux/${version}/discord-ptb-${version}.tar.gz";
          sha256 = "1rlj76yhxjwwfmdln3azjr69hvfx1bjqdg9jhdn4fp6mlirkrcq4";
        };
      }))
      (pkgs.discord-canary.overrideAttrs (old :rec{
         version = "0.0.131";
         src = fetchurl {
           url = "https://dl-canary.discordapp.net/apps/linux/${version}/discord-canary-${version}.tar.gz";
           sha256 = "087rzyivk0grhc73v7ldxxghks0n16ifrvpmk95vzaw99l9xv0v5";
         };
       }))
      (pkgs.betterdiscord-installer.overrideAttrs (old: rec{
        pname = "betterdiscord-installer";
        version = "1.0.0-hotfix";
        name = "${pname}-${version}";
        src = fetchurl {
         url = "https://github.com/BetterDiscord/Installer/releases/download/v${version}/Betterdiscord-Linux.AppImage";
         sha256 = "0p1jgxm1q8f01bffirvgx5wq5adwqm0lprvqxwlv8r74g7hgm01y";
        };
      }))
  ];
}