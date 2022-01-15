{ pkgs, ... }:

{
    imports =
      [
        ./ssh.nix
       # ./wireguard.nix
        ./nextcloud.nix
        ./mariadb.nix
      ];
}
