{
  lib,
  config,
  ...
}: {
  networking.networkmanager.ensureProfiles.profiles."wifi-@dev_null" = rec {
    connection = {
      id = "@dev_null";
      type = "wifi";
    };
    wifi = {
      mode = "infrastructure";
      ssid = connection.id;
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk = "$WIFI_${lib.toUpper (builtins.replaceStrings ["@"] [""] connection.id)}_PSK";
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
}
