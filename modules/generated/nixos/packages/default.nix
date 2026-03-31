{
  pkgs,
  lib,
  config,
  ...
}: {
  generated.packages = {
    btrfs-tools.enable = lib.mkDefault true;
    tui.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    development.enable = lib.mkDefault true;
    networking.enable = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    # Utilities
    coreutils
    netcat-gnu
    stress
    # pee sponge vipe etc..
    moreutils

    lshw

    # man page
    man
    man-pages
    man-pages-posix
    #(pkgs.linux-manual.override {
    #  linuxPackages_latest = config.boot.kernelPackages;
    #})

    # Archives
    lrzip
    unrar-wrapper

    mat2 # meta data stripper
    # onionshare

    usbutils

    # Commands
    navi # interactive tldr
    most
    sshfs
    pssh
    killall
    pciutils
    xxd

    pkg-config
    dbus
  ];
}
