{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    extraConfig = ''
      VisualHostKey yes
    '';
    matchBlocks = {
      "oracle" = {
        hostname = "130.61.112.64";
        user = "martin";
      };
      "brnikov" = {
        hostname = "10.100.0.2";
        user = "martin";
        extraOptions = {"ProxyJump" = "oracle";};
      };
      "ha-home" = {
        hostname = "10.100.0.4";
        user = "martin";
        extraOptions = {"ProxyJump" = "oracle";};
      };
      "NAT" = {
        hostname = "192.168.0.1";
        user = "kolobozka6b";
        extraOptions = {
          "HostKeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedKeyTypes" = "+ssh-rsa";
        };
      };
      "idk" = {
        hostname = "10.100.0.3";
        user = "martin";
      };
      "fray1" = {hostname = "fray1.fit.cvut.cz";};
      "fray2" = {hostname = "fray2.fit.cvut.cz";};
      "fray*" = {
        user = "kosmart5";
        extraOptions = {
          "HostKeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedKeyTypes" = "+ssh-rsa";
        };
      };
      "*.cdn77.eu" = {user = "martin.kos";};
      "*.cdn77.com" = {user = "martin.kos";};
      "cdn-dev-ams-1" = {
        hostname = "edge-mc-ams-dev-1-185-152-65-89.cdn77.com";
      };
      "cdn-dev-ams-2" = {
        hostname = "edge-mc-ams-dev-2-185-152-65-22.cdn77.com";
      };
      "cdn-dev-fra-3" = {
        hostname = "edge-mc-fra-dev-3-185-152-65-42.cdn77.com";
      };
      "cdn-dev-fra-4" = {
        hostname = "edge-mc-fra-dev-4-185-152-65-43.cdn77.com";
      };
      "cdn-dev-prg-5" = {
        hostname = "edge-mc-prg-dev-5-185-152-65-88.cdn77.com";
      };
      "cdn-dev-prg-6" = {
        hostname = "edge-mc-prg-dev-6-185-152-65-83.cdn77.com";
      };
      "cdn-dev-prg-7" = {
        hostname = "edge-mc-prg-dev-7-185-152-65-84.cdn77.com";
      };
      "cdn-dev-prg-8" = {
        hostname = "edge-mc-prg-dev-8-45-136-152-18.cdn77.com";
      };
      "cdn-dev-me" = {
        hostname = "others-mc-dev-martinkos-45-136-152-121.cdn77.eu";
      };
      "cdn-http3-testing" = {
        hostname = "edge-mc-prg-84-17-61-108.cdn77.com";
      };
    };
  };
}
