{ pkgs, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts."dev-null.me" = {
      root = "/var/www";
      locations."~ /\\.git".extraConfig = ''
        deny all;
      '';
    };
  };
}
