{ pkgs, ... }:

let
  username = "martin";
  domain = "sync.me";
in {
  # default port is 8384
  networking.extraHosts = ''
    127.0.0.1 ${domain}
  '';

  services.syncthing = {
    enable = true;
    user = username;
    dataDir =
      "/home/${username}/Documents"; # Default folder for new synced folders
    configDir =
      "/home/${username}/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
  };
}
