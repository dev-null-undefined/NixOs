{pkgs, ...}: {
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-nettool

    networkmanagerapplet

    insomnia # REST API Client

    burpsuite # proxy

    zap # Web crawler

    kiterunner # content discovery tool
  ];
}
