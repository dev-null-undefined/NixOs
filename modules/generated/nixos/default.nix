{
  pkgs,
  lib,
  config,
  ...
}: {
  generated = {
    users.enable = lib.mkDefault true;
    packages.enable = lib.mkDefault true;
    services.enable = lib.mkDefault true;
    documentation.enable = lib.mkDefault true;
  };

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

  # get completion for system packages (e.g. systemd).
  environment.pathsToLink = ["/share/zsh"];

  # sandboxing
  programs.firejail.enable = true;
  security.apparmor.enable = true;
}
