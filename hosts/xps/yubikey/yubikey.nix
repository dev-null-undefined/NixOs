{pkgs, ...}: {
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [yubikey-personalization];

  services.yubikey-agent.enable = true;

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
