{
  services.nginx.virtualHosts."default" = {
    default = true;
    serverName = "_"; # Catch all domain
    locations."/" = {
      extraConfig = ''
        return 404;
      '';
    };
    extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';
  };
}
