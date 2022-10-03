{ pkgs, ... }:

{
    imports =
      [
       # ./ssh.nix
       # ./nginx.nix
       # ./wireguard.nix
       # ./wireguard-client.nix
       # ./nextcloud.nix
        ./mariadb.nix
       # ./openvpn.nix
      ];
}
