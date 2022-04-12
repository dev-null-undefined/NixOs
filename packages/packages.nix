{ pkgs, config, ... }:

{
  imports = [ ./common.nix ./zsh.nix ./gui/gui.nix ./docker.nix ];

  environment.systemPackages = with pkgs; [
    # ----- Terminal tools -----
    # TUI
    lynx
    android-tools
    bpytop
    glances
    gotop
    nload
    iftop
    nethogs
    bottom
    mutt
    nyancat
    pipes
    cmatrix
    hyperfine
    mycli
    wavemon
    wirelesstools
    iw
    screenfetch
    neofetch
    cpufetch
    macchina

    # Commands
    home-manager
    gnumake
    feh
    youtube-dl
    asciinema

    # Utilities
    pandoc
    light
    blueman
    fzf
    autorandr
    cron
    bat
    lolcat
    libnotify
    libinput-gestures
    xclip
    hunspell
    aspell
    gspell
    languagetool
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # Libs
    xorg.libX11
    xorg.libXinerama
    xorg.libXft
    imlib2
    ncurses

    # dev tools
    valgrind

    hidapi
  ];
  nixpkgs.config = {
    allowUnfree = true;
    #allowBroken = true;
  };

}
