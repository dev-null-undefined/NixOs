{ pkgs, ... }:

{
  imports = [
    # ./ssh.nix
    # ./nginx.nix
    # ./wireguard.nix
    # ./wireguard-client.nix
    # ./nextcloud.nix
    ./mariadb.nix
    ./syncthing.nix
    # ./openvpn.nix
  ];
}
