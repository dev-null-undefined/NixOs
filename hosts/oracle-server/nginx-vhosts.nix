{
  pkgs,
  config,
  ...
}: let
  visualSorting = pkgs.fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "VisualSorting";
    rev = "2b36d720ea0bb944ddb8352cc1c1b125a399bcc0";
    sha256 = "sha256-H/qSpJglOE1DhVfxSbM0Sac774erNhSoxCr7QRnvU0U=";
  };
in {
  services.nginx.virtualHosts = {
    "${config.domain}" = {
      enableACME = true;
      forceSSL = true;
      http3 = true;
      root = visualSorting;
      locations."~ /\\.git".extraConfig = ''
        deny all;
      '';
    };
    "cpp.${config.domain}" = {
      enableACME = true;
      forceSSL = true;
      http3 = true;
      root = "${pkgs.cppreference-doc.outPath}/share/cppreference/doc/html";
      locations."= /".extraConfig = ''
        return 301 /en;
      '';
    };
    "nixos.${config.domain}" = {
      enableACME = true;
      forceSSL = true;
      http3 = true;
      root = "${config.system.build.manual.manualHTML}/share/doc/nixos";
    };
    "dynmap.${config.domain}" = {
      enableACME = true;
      forceSSL = true;
      http3 = true;
      locations."/" = {
        proxyPass = "http://135.125.16.193:8034";
        proxyWebsockets = true;
      };
    };
  };
}
