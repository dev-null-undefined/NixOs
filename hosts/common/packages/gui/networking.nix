{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome.gnome-nettool

    networkmanagerapplet

    wireshark

    insomnia # REST API Client

    burpsuite # proxy

    kiterunner # content discovery tool
  ];
}
