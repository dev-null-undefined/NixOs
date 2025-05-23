{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-3d-effect
      droidcam-obs
      input-overlay
      obs-multi-rtmp
      obs-shaderfilter
      looking-glass-obs
      obs-vintage-filter
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
}
