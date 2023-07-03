{pkgs, ...}: {
  programs = {
    bandwhich.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Network monitors
    iftop
    nload
    nethogs
    gping # TUI ping with graph

    wavemon
    wirelesstools
    iw
  ];
}
