{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    v4l-utils
    droidcam

    # Audio control
    stable.easyeffects
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

    master.kodi

    # Images
    feh

    # CAD editor
    freecad
  ];
}
