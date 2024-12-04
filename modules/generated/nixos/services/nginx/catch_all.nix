{
  services.nginx.virtualHosts."default" = {
    default = true;
    serverName = "_"; # Catch all domain
    locations."/" = {
      extraConfig = ''
        access_log  /var/log/nginx/access.log  main;
        return 404;
      '';
    };
  };
}
