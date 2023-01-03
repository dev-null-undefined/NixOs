{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./docker.nix ./languages/default.nix];

  environment.systemPackages = with pkgs; [
    cloc # line counter
    pv # pipe monitor

    # Networking
    nmap # network scanner
    tcpdump # packet analyzer
    traceroute
    mitmproxy # https proxy
    whois # domain lookup
    dnsutils # dig, nslookup, etc.

    # Git utils
    git
    # github tui
    gh

    gnupg
    lsof
    file
    fd
  ];
}
