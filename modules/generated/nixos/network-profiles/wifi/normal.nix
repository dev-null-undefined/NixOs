{
  lib,
  config,
  ...
}: let
  data = import ./_normal.nix;
  generate = cfg: let
    inherit (cfg) name;
    key = lib.toUpper (builtins.replaceStrings ["@" "-"] ["" "_"] name);
  in {
    "wifi-${name}" = {
      connection = {
        id = name;
        type = "wifi";
      };
      wifi = {
        mode = "infrastructure";
        ssid = name;
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_${key}_PSK";
      };
      ipv4 = {
        dns = "${builtins.concatStringsSep ";" config.networking.nameservers};";
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
    };
  };
in {
  networking.networkmanager.ensureProfiles.profiles =
    lib.fold (a: b: a // b) {} (builtins.map generate data);
}
