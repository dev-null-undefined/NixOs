{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      user = "martin";
      hashKnownHosts = true;
    };
    extraConfig = ''
      VisualHostKey yes
    '';
  };
}
