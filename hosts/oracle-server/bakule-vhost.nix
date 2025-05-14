{config, ...}: let
  kubik-source-domain = "source.kubik.${config.domain}";

  bakule-timer-flake =
    builtins.getFlake
    "github:dev-null-undefined/bakule-timer/96213dcca47c36eae632a560e496daa087643e4a";

  bakule-uzdil-pkg =
    bakule-timer-flake.packages.${config.nixpkgs.system}.bakule-timer-uzdil;

  bakule-uzdil-path = "${bakule-uzdil-pkg}/share/bakule-timer";

  bakule-kubik-path = "${
    bakule-uzdil-pkg.override {
      pdf_url = "https://${kubik-source-domain}";
      domain = "bc.kubik.${config.domain}";
      author = "jakub.charvat";
    }
  }/share/bakule-timer";

  bakule-posledni-path = "${
    bakule-uzdil-pkg.override {
      pdf_url = "https://lastaapps.sh.cvut.cz/public.php/dav/files/MZkFk4LgFyGgfzc";
      domain = "bc.posledni.${config.domain}";
      author = "petr.lastovicka";
    }
  }/share/bakule-timer";

  conf-common = {
    enableACME = true;
    forceSSL = true;
    http3 = true;
    extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';
  };

  conf-bakule =
    {
      locations = {
        "/".tryFiles = "$uri $uri/ $uri.php";
        "~ \\.php$".extraConfig = ''
          fastcgi_pass  unix:${config.services.phpfpm.pools.bakule.socket};
        '';
      };
    }
    // conf-common;

  conf-uzdil = {root = bakule-uzdil-path;} // conf-bakule;

  conf-kubik = {root = bakule-kubik-path;} // conf-bakule;

  conf-posledni = {root = bakule-posledni-path;} // conf-bakule;

  conf-kubik-source =
    {
      locations."/" = {proxyPass = "http://localhost:9989";};
    }
    // conf-common;
in {
  services.nginx.virtualHosts = {
    "bc.${config.domain}" = conf-uzdil;
    "bc.gde.${config.domain}" = conf-uzdil;
    "bc.kde.${config.domain}" = conf-uzdil;

    "bc.kubik.${config.domain}" = conf-kubik;

    "bc.posledni.${config.domain}" = conf-posledni;

    "${kubik-source-domain}" = conf-kubik-source;
  };
  services.phpfpm.pools.bakule = {
    user = "nginx";
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
