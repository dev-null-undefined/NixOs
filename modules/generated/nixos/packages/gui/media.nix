{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    v4l-utils
    droidcam

    # Audio control
    easyeffects
    pavucontrol

    # Editing
    shotcut
    davinci-resolve

    ardour
    audacity

    blender
    krita
    gimp-with-plugins

    darktable

    # Hand written notes
    xournalpp
    rnote

    # Video
    vlc
    mpv

    kodi

    # Images
    feh

    # CAD editor
    freecad
  ];
}
