{
  config,
  pkgs,
  lib,
  ...
}: {
#  imports = [./docker.nix];

  environment.systemPackages = with pkgs; [
    cloc # line counter
    pv # pipe monitor

    # Networking
    ngrok # expose a web server running on your local machine
    nmap # network scanner
    tcpdump # packet analyzer
    netdiscover # quick LAN scanner
    traceroute
    mitmproxy # https proxy
    whois # domain lookup
    dnsutils # dig, nslookup, etc.
    dogdns

    # Git utils
    git
    # github tui
    gh
    lazygit # tui git client

    gnupg
    lsof
    file
    fd
  ];
}
