{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    extraConfig = ''
      VisualHostKey yes
    '';
  };
}
