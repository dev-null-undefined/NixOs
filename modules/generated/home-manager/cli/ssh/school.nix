{
  programs.ssh.matchBlocks = {
    "fray1" = {hostname = "fray1.fit.cvut.cz";};
    "fray2" = {hostname = "fray2.fit.cvut.cz";};
    "fray*" = {
      user = "kosmart5";
      extraOptions = {
        "HostKeyAlgorithms" = "+ssh-rsa";
        "PubkeyAcceptedKeyTypes" = "+ssh-rsa";
      };
    };
  };
}
