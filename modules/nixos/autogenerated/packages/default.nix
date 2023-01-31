{
  pkgs,
  config,
  lib,
  ...
}: {
  generated.packages.btrfs-tools.enable = lib.mkDefault true;
  generated.packages.tui.enable = lib.mkDefault true;
  generated.packages.zsh.enable = lib.mkDefault true;
  generated.packages.development.enable = lib.mkDefault true;

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
    lrzip
    unrar-wrapper

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
    navi # interactive tldr
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
