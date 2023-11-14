{pkgs, ...}: {
  programs = {
    bandwhich.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Network monitors
    bmon
    iptraf-ng
    iftop
    nload
    nethogs
    tcptrack

    gping # TUI ping with graph

    wavemon
    wirelesstools
    iw
  ];
}
