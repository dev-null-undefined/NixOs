{ pkgs, config, lib, ... }:

{
  imports = [
    ./tui.nix
    ./zsh.nix
    ./development/ides/default.nix
    ./development/default.nix
  ];

  environment.systemPackages = with pkgs; [
    # Utilities
    coreutils
    netcat-gnu
    # pee sponge vipe etc..
    moreutils

    # man page
    man
    man-pages

    # Archives
    unzip
    zip
    unrar-wrapper

    # nix tools
    nix-diff
    nix-index
    nix-direnv
    nix-output-monitor

    direnv
    ripgrep
    jq # json
    bc # calculator
    mat2 # meta data stripper
    onionshare

    usbutils
    dhcp

    # Commands
    delta # diff
    tmux # term multiplexor
    tealdeer
    tree
    most
    sshfs
    openssh
    openssl
    killall
    thefuck
    pciutils

    # multimedia manipulation
    ffmpeg
    imagemagick

    # Utilities
    wget
    curl

    pkg-config
    dbus
  ];

}