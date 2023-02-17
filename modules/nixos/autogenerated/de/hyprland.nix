{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  generated = {
    de.enable = true;
    nvidia.nvidia-sync.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xdg-utils
  ];

  security.pam.services.swaylock.u2fAuth = true;

  programs = {
    hyprland = {
      package = pkgs.hyprland-nvidia;
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
    };

    wshowkeys.enable = true;
    light.enable = true;
    kdeconnect.enable = true;
  };

  services.getty.autologinUser = "martin";

  environment.sessionVariables = {
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "QT_QPA_PLATFORM" = "wayland";
    "XDG_CURRENT_DESKTOP" = "sway";
    "XDG_SESSION_DESKTOP" = "sway";
  };
}
