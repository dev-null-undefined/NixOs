{pkgs, ...}: {
  home.packages = with pkgs; [
    grim
    imv
    mimeo
    slurp
    waypipe
    wf-recorder
    wl-clipboard
    wl-mirror
    wlr-randr

    wdisplays
    wev

    ydotool

    ncpamixer
    pulseaudio
    pamixer
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    _JAVA_AWT_WM_NONREPARENTING = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
  };
}
