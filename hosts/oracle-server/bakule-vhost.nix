{config, ...}: let
  bakule-timer =
    builtins.getFlake
    "github:dev-null-undefined/bakule-timer/e0b000e6c3ee9a048890baa1983a2207c673cc11";
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
    locations = {
      "/".tryFiles = "$uri $uri/ $uri.php";
      "~ \\.php$".extraConfig = ''
        fastcgi_pass  unix:${config.services.phpfpm.pools.bakule.socket};
      '';
    };
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
