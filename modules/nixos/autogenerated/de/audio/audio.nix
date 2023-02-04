{pkgs, ...}: {
  #imports = [
    # ./pulse.nix
  #  ./pipewire.nix
  #];
  environment.systemPackages = with pkgs; [
    playerctl
    pulseaudio
    patchage
    carla
    qjackctl
    alsa-utils
    alsa-lib
    alsa-plugins
    jack2
  ];
}
