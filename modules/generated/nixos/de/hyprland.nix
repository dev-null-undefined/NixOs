{
  pkgs,
  lib,
  ...
}: {
  system.nixos.tags = ["hyprland"];
  generated = {
    de.enable = true;
    nvidia.nvidia-sync.enable = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    xdg-utils
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
    libsForQt5.polkit-kde-agent

    wl-clipboard
  ];

  services = {
    blueman.enable = true;
    pipewire.wireplumber.enable = true;
  };

  security = {
    pam.services.swaylock.u2fAuth = true;
    polkit.enable = true;
  };

  programs = {
    hyprland = {
      package = hyprland-pkg;
      enable = true;
      enableNvidiaPatches = true;
      xwayland = {
        enable = true;
      };
    };

    wshowkeys.enable = true;
    light.enable = true;
    kdeconnect.enable = true;
  };

  #services.getty.autologinUser = "martin";

  services.xserver = {
    displayManager = {
      sessionPackages = [hyprland-pkg];
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  environment.sessionVariables = {
    "MOZ_ENABLE_WAYLAND" = "1";
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "QT_QPA_PLATFORM" = "wayland";
    "XDG_CURRENT_DESKTOP" = "sway";
    "XDG_SESSION_DESKTOP" = "sway";
    "WLR_NO_HARDWARE_CURSORS" = "1"; # https://wiki.hyprland.org/FAQ/#me-cursor-no-render
  };
}
