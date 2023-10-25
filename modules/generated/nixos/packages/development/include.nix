{pkgs, ...}: {
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

    android-tools # adb

    # Git utils
    git
    # github tui
    gh
    lazygit # tui git client

    gnupg
    lsof
    file
    fd

    graphviz # generating graphs dot

    # Hacking tools
    aircrack-ng
    hashcat
    john
  ];
}
