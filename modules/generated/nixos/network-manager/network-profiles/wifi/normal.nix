{
  lib,
  config,
  ...
}: let
  data = import ./_normal.nix;
  generate = {
    name,
    security ? "wpa-psk",
    band ? "",
    ...
  }: let
    secret_prefix = "$WIFI_${
      lib.toUpper (builtins.replaceStrings ["@" "-"] ["" "_"] name)
    }";
  in {
    "wifi-${name}" =
      {
        connection = {
          id = name;
          type = "wifi";
        };
        wifi =
          {
            mode = "infrastructure";
            ssid = name;
          }
          // (lib.optionalAttrs (band != "") {inherit band;});
        wifi-security =
          {
            key-mgmt = security;
          }
          // lib.optionalAttrs (security == "wpa-psk") {
            psk = "${secret_prefix}_PSK";
          };
        ipv4 = {
          dns = "${builtins.concatStringsSep ";" config.networking.nameservers};";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "disabled";
        };
      }
      // lib.optionalAttrs (security == "wpa-eap") {
        "802-1x" = {
          eap = "ttls;";
          identity = "${secret_prefix}_NAME";
          password = "${secret_prefix}_PASSWORD";
          phase2-auth = "mschapv2";
        };
      };
  };
in {
  networking.networkmanager.ensureProfiles.profiles =
    lib.fold (a: b: a // b) {} (builtins.map generate data);
}
