{
  programs.ssh.matchBlocks = {
    "NAT" = {
      hostname = "192.168.0.1";
      user = "kolobozka6b";
      extraOptions = {
        "HostKeyAlgorithms" = "+ssh-rsa";
        "PubkeyAcceptedKeyTypes" = "+ssh-rsa";
      };
    };
  };
}
