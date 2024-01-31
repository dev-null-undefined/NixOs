{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.stable.obs-studio-plugins; [
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
