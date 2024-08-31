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
    stable.mitmproxy # https proxy
    whois # domain lookup
    dnsutils # dig, nslookup, etc.
    dogdns

    apacheHttpd # appache benchmark tool ab

    android-tools # adb

    # Git utils
    git
    # github tui
    gh
    lazygit # tui git client

    lsof
    file
    fd

    rng-tools # testing and generating random numbers

    graphviz # generating graphs dot

    # Hacking tools
    aircrack-ng
    hashcat
    john

    rpi-imager # Raspberry pi imaging utility

    dpkg
  ];
}
