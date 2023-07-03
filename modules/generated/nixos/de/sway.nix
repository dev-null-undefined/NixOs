{pkgs, ...}: {
  generated = {
    de.enable = true;
    nvidia.nvidia-sync.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xdg-utils
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
  ];

  services.blueman.enable = true;

  security = {
    pam.services.swaylock.u2fAuth = true;
    polkit.enable = true;
  };

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    wshowkeys.enable = true;
    light.enable = true;
    kdeconnect.enable = true;
  };

  environment.sessionVariables = {
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "QT_QPA_PLATFORM" = "wayland";
    "XDG_CURRENT_DESKTOP" = "sway";
    "XDG_SESSION_DESKTOP" = "sway";
  };
}
