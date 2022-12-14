{ pkgs, config, ... }:

{
  imports = [ ./common.nix ./zsh.nix ./gui/gui.nix ./docker.nix ./vim.nix ];

  environment.systemPackages = with pkgs; [
    stable.android-tools

    # ----- Terminal tools -----
    # TUI
    broot # cd with fd and fzf

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

    # Funny programs
    nyancat
    pipes
    cmatrix
    sl

    hyperfine # terminal benchmark

    mycli # mariadb TUI server connector

    wavemon
    wirelesstools
    iw

    # Flex spec sharing Utilities
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
    fzf
    autorandr
    cron
    bat
    lolcat
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
