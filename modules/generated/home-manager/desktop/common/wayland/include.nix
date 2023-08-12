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
}
