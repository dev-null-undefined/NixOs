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

    stable.blender
    krita
    gimp-with-plugins

    darktable

    # Hand written notes
    xournalpp
    rnote

    # Audio
    spotifywm
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
