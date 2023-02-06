{pkgs, ...}: {
  generated.de.audio.pipewire.enable = true;
  generated.de.audio.pulse.enable = false;

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
