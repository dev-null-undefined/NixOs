{pkgs, ...}: let
  username = "martin";
in {
  # default port is 8384
  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}/Documents"; # Default folder for new synced folders
    configDir = "/home/${username}/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
  };
}
