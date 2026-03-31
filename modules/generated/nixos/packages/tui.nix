{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # ----- Terminal tools -----
    # TUI
    termdown # timer/stopwatch
    tre-command # better tree

    mc # file manager
    ranger # file manager
    aria2 # download utility
    lynx # web browser
    browsh # better web browser

    httpie # command line HTTP client

    hydra-check # check for sucessfull build or failiure on hydra

    # Usage monitors
    (btop.override {cudaSupport = true;})
    glances
    gotop
    atop
    zenith

    mutt # email client

    # Commands
    home-manager
    yt-dlp
    asciinema

    # Utilities
    pandoc
    brightnessctl
    autorandr
    cron
    libnotify
    libinput-gestures
    xclip

    # Libs
    libx11
    libxinerama
    libxft
    imlib2
    ncurses

    hidapi
  ];
}
