{
  pkgs,
  lib,
  ...
}: {
  system.nixos.tags = ["hyprland"];
  generated = {
    de.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xdg-utils
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
    kdePackages.polkit-kde-agent-1

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
      enable = true;
      xwayland = {enable = true;};
    };

    wshowkeys.enable = true;
    light.enable = true;
    kdeconnect.enable = true;
  };

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  #services.xserver.displayManager.gdm = {
  #  enable = true;
  #  wayland = true;
  #};

  # xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  environment.sessionVariables = {
    "MOZ_ENABLE_WAYLAND" = "1";
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "QT_QPA_PLATFORM" = "wayland";
    "NIXOS_OZONE_WL" = "1";
    "XDG_CURRENT_DESKTOP" = "Hyprland";
    "XDG_SESSION_DESKTOP" = "sway";
    "WLR_NO_HARDWARE_CURSORS" = "1"; # https://wiki.hyprland.org/FAQ/#me-cursor-no-render
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 80;

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 50; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 90; # 80 and above it stops charging
    };
  };
}
