{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".hashKnownHosts = true;
    extraConfig = ''
      VisualHostKey yes
    '';
  };
}
