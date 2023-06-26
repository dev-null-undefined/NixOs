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
    shotcut

    ardour
    audacity

    blender
    krita
    gimp-with-plugins

    # Hand written notes
    xournalpp
    rnote

    # Audio
    stable.spotifywm
    #spotify

    # Video
    vlc
    mpv

    # Images
    feh

    # CAD editor
    freecad
  ];
}
