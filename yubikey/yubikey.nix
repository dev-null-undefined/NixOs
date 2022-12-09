{ config, pkgs, lib, ... }:

{
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  services.yubikey-agent.enable = true;

  boot.initrd.luks = {
    gpgSupport = true;
    devices.root.gpgCard = {
      gracePeriod = 5;
      encryptedPass = ./. + "/pass-phrase.gpg";
      publicKey = ./. + "/public-yubikey.asc";
    };
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-manager-qt
    yubikey-touch-detector
    yubikey-personalization
    yubikey-personalization-gui

    gnupg
    pinentry-curses
    pinentry-qt
    paperkey

    pam_u2f
  ];
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
}
