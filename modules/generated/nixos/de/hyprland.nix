{pkgs, ...}: let
  hyprland-pkg = pkgs.hyprland-nvidia;
in {
  system.nixos.tags = ["hyprland"];
  generated = {
    de.enable = true;
    nvidia.nvidia-sync.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xdg-utils
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
  ];

  services = {
    blueman.enable = true;
    pipewire.wireplumber.enable = true;
  };

  security.pam.services.swaylock.u2fAuth = true;

  programs = {
    hyprland = {
      package = hyprland-pkg;
      enable = true;
      nvidiaPatches.enable = true;
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
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "QT_QPA_PLATFORM" = "wayland";
    "XDG_CURRENT_DESKTOP" = "sway";
    "XDG_SESSION_DESKTOP" = "sway";
    "WLR_NO_HARDWARE_CURSORS" = "1"; # https://wiki.hyprland.org/FAQ/#me-cursor-no-render
  };
}
