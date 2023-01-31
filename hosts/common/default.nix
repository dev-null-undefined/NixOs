{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./users/default.nix ./packages/default.nix ./services/default.nix];

  # Change default time limit for unit stop
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
  '';

  programming-languages.enable = lib.mkDefault true;

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

    man = {
      enable = true;
      generateCaches = true;
    };
  };

  # get completion for system packages (e.g. systemd).
  environment.pathsToLink = ["/share/zsh"];

  # sandboxing
  programs.firejail.enable = true;
  security.apparmor.enable = true;
}
