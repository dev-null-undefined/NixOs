{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    # ----- Terminal tools -----
    # TUI
    procs # better ps
    du-dust # better du
    duf # better df
    ncdu # TUI windirstat
    termdown # timer/stopwatch

    mc # file manager
    ranger # file manager
    aria # download utility
    lynx # web browser

    # Usage monitors
    bpytop
    glances
    gotop
    htop
    atop
    bottom

    # Network monitors
    iftop
    nload
    nethogs
    gping # TUI ping with graph

    mutt # email client

    hyperfine # terminal benchmark

    wavemon
    wirelesstools
    iw

    # Commands
    home-manager
    youtube-dl
    asciinema

    # Utilities
    pandoc
    light
    autorandr
    cron
    libnotify
    libinput-gestures
    xclip

    # Libs
    xorg.libX11
    xorg.libXinerama
    xorg.libXft
    imlib2
    ncurses

    hidapi
  ];
}
