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
    ldns # drill for testing how fast the dns is

    apacheHttpd # appache benchmark tool ab
    wrk

    openresty
    groff

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

    postman

    libqalculate # qalc

    lnav

    kcat

    sqlite
  ];
}
