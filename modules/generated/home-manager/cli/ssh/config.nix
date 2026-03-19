{
  programs.ssh = {
    enable = true;
    matchBlocks."*".hashKnownHosts = true;
    extraConfig = ''
      VisualHostKey yes
    '';
  };
}
