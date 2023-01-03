{ pkgs, ... }:
let
  visualSorting = pkgs.fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "VisualSorting";
    rev = "2fdedd6bab68384536ece120ec940fde7b8a024a";
    sha256 = "sha256-2ZeHGvGSrbyuppjzIsnkZTKi7mPXlJuLy9ksOnqeFrs=";
  };
in {
  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."dev-null.me" = {
      addSSL = true;
      enableACME = true;
      forceSSL = true;
      root = visualSorting;
      locations."~ /\\.git".extraConfig = ''
        deny all;
      '';
    };
  };
}
