{pkgs, ...}: {
  programs = {
    bandwhich.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # ----- Terminal tools -----
    # TUI
    procs # better ps
    du-dust # better du
    duf # better df
    ncdu # TUI windirstat
    termdown # timer/stopwatch
    tre-command # better tree

    mc # file manager
    ranger # file manager
    aria # download utility
    lynx # web browser
    browsh # better web browser

    httpie # command line HTTP client

    hydra-check # check for sucessfull build or failiure on hydra

    # Usage monitors
    btop
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
