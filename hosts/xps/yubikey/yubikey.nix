{pkgs, ...}: {
  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [yubikey-personalization];

    yubikey-agent.enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
    #yubikey-manager-qt
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
