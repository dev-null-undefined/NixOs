{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    v4l-utils
    droidcam

    # Recording and streaming
    obs-studio

    # Audio control
    easyeffects
    pavucontrol

    # Editing
    stable.shotcut

    ardour
    audacity

    blender
    krita
    stable.gimp-with-plugins

    # Hand written notes
    xournalpp
    rnote

    # Audio
    spotify

    # Video
    vlc
    mpv

    # Images
    feh
  ];
}
