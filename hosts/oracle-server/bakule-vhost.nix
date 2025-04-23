{config, ...}: let
  bakule-timer =
    builtins.getFlake
    "github:dev-null-undefined/bakule-timer/143e4f8ee5c0c486843c5862742ec20063e34efe";
  bakule-path = "${
    bakule-timer.packages.${config.nixpkgs.system}.bakule-timer
  }/share/bakule-timer";
  conf = {
    root = bakule-path;
    enableACME = true;
    forceSSL = true;
    http3 = true;
    extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';
    locations."~ \\.php$".extraConfig = ''
      fastcgi_pass  unix:${config.services.phpfpm.pools.bakule.socket};
    '';
  };
in {
  services.nginx.virtualHosts = {
    "bc.${config.domain}" = conf;
    "bc.gde.${config.domain}" = conf;
    "bc.kde.${config.domain}" = conf;
  };
  services.phpfpm.pools.bakule = {
    user = "nobody";
    settings = {
      "pm" = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };
}
