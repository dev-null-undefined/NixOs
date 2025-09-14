{
  networking.networkmanager.ensureProfiles.profiles."vpn-cdn77" = {
    connection = {
      id = "CDN77 VPN";
      type = "wireguard";
      interface-name = "wg-cdn77";
      autoconnect = false;
    };
    wireguard = {
      listen-port = 51821;
      private-key = "$VPN_CDN77_PRIVATE_KEY";
    };
    "wireguard-peer.0VIFZvHOSiL4PbIUk5Zig3+Oj7UseZE05/Jt3JG3MjM=" = {
      endpoint = "remote.cdn77.com:7777";
      allowed-ips = "0.0.0.0/0";
    };
    ipv4 = {
      address1 = "10.0.5.220/32";
      dns = "8.8.8.8;";
      dns-search = "~;";
      method = "manual";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "disabled";
    };
  };
}
