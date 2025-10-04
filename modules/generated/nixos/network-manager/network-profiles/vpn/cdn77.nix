{
  lib,
  config,
  ...
}: let
  cf = config.generated.network-manager.network-profiles.vpn.cdn77;
in {
  options = {
    address = lib.mkOption {
      type = lib.types.str;
      description = "Internall IPv4 address";
    };
    privateKeySuffix = lib.mkOption {
      type = lib.types.str;
      description = "Private key suffix from the ENV variables secrets";
      example = "_X1";
      default = "";
    };
  };
  networking.networkmanager.ensureProfiles.profiles."vpn-cdn77" = {
    connection = {
      id = "CDN77 VPN${cf.privateKeySuffix}";
      type = "wireguard";
      interface-name = "wg-cdn77";
      autoconnect = false;
    };
    wireguard = {
      listen-port = 51821;
      private-key = "$VPN_CDN77_PRIVATE_KEY${cf.privateKeySuffix}";
    };
    "wireguard-peer.0VIFZvHOSiL4PbIUk5Zig3+Oj7UseZE05/Jt3JG3MjM=" = {
      endpoint = "remote.cdn77.com:7777";
      allowed-ips = "0.0.0.0/0";
    };
    ipv4 = {
      address1 = "${cf.address}/32";
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
