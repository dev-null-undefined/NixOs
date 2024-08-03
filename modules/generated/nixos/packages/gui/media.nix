{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    v4l-utils
    droidcam

    # Audio control
    easyeffects
    pavucontrol

    # Editing

    ardour
    audacity

    blender
    krita
    gimp-with-plugins

    stable.darktable

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
