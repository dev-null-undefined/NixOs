{ pkgs, config, ... }:

{
  imports = [ ./common.nix ./zsh.nix ./gui/gui.nix ./docker.nix ./vim.nix ];

  environment.systemPackages = with pkgs; [
    # ----- Terminal tools -----
    # TUI
    procs # better ps
    du-dust # better du
    duf # better df
    ncdu # TUI windirstat
    termdown # timer/stopwatch

    mc # file manager
    aria # download utility
    lynx # web browser

    # Usage monitors
    bpytop
    glances
    gotop
    zenith
    htop
    atop
    nvitop
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
    gnumake
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

    # dev tools
    valgrind

    hidapi
  ];
}
