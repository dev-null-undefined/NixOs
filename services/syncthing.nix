{ pkgs, ... }:

let
  username = "martin";
  domain = "sync.me";
in {
  networking.extraHosts = ''
    127.0.0.1 ${domain}
  '';
  services.nginx = {
    enable = true;
    virtualHosts.domain = {
      locations = { "/" = { proxyPass = "http://localhost:8384"; }; };
    };
  };
  services = {
    syncthing = {
      enable = true;
      user = username;
      dataDir =
        "/home/${username}/Documents"; # Default folder for new synced folders
      configDir =
        "/home/${username}/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };
}
