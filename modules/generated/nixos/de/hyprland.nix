{
  config,
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
    brightnessctl
  ];

  services = {
    blueman.enable = true;
    pipewire.wireplumber.enable = true;
  };

  security = {
    pam.services.hyprlock.u2f.enable = true;
    polkit.enable = true;
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland = {enable = true;};
      # UWSM manages the Hyprland session via systemd, which fixes GDM 50 not
      # registering non-GNOME wayland sessions ("Session never registered").
      # https://github.com/NixOS/nixpkgs/issues/523332
      withUWSM = true;
    };

    wshowkeys.enable = true;
    kdeconnect.enable = true;
  };

  services.displayManager.gdm = {
    enable = true;
  };

  # Without an explicit default, GDM 50 falls back to launching `gnome-session`
  # for the user session — which never registers here (no full GNOME), so login
  # bounces back to the greeter. Force the UWSM-managed Hyprland session.
  services.displayManager.defaultSession = "hyprland-uwsm";

  # Workaround for GDM 50 not finding gnome-session in PATH on NixOS.
  # Upstream fix is in nixpkgs master (PR #523948, merged 2026-06-02) but not
  # yet promoted to nixos-unstable. Remove once channel catches up.
  # https://github.com/NixOS/nixpkgs/issues/523332
  security.pam.services.gdm-launch-environment.rules.session.env-greeter = {
    order = config.security.pam.services.gdm-launch-environment.rules.session.systemd.order - 50;
    control = "required";
    modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
    settings = {
      conffile = let
        env = config.services.displayManager.generic.environment;
      in
        pkgs.writeText "gdm-launch-environment-env-conf" ''
          PATH          DEFAULT="''${PATH}:${pkgs.gnome-session}/bin"
          XDG_DATA_DIRS DEFAULT="''${XDG_DATA_DIRS}:${env.XDG_DATA_DIRS}"
        '';
      readenv = 0;
    };
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

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      RESTORE_THRESHOLDS_ON_BAT = 1; # Restore tresh holds on AC disconect

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 50; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
  };
}
