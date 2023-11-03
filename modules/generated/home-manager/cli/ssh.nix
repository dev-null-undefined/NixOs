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
      "fray1" = {
        hostname = "fray1.fit.cvut.cz";
      };
      "fray2" = {
        hostname = "fray2.fit.cvut.cz";
      };
      "fray*" = {
        user = "kosmart5";
        extraOptions = {
          "HostKeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedKeyTypes" = "+ssh-rsa";
        };
      };
    };
  };
}
