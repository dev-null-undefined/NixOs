{
  pkgs,
  config,
  ...
}: {
  imports = [./users/default.nix ./packages/default.nix ./services/default.nix];

  # Change default time limit for unit stop
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
  '';

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "Europe/Prague";

  # man pages
  documentation = {
    enable = true;

    dev.enable = true;
    doc.enable = true;

    info.enable = true;
    man.enable = true;
  };

  # sandboxing
  programs.firejail.enable = true;
  security.apparmor.enable = true;
}
