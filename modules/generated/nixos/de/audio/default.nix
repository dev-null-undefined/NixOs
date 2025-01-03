{
  pkgs,
  lib,
  ...
}: {
  generated.de.audio.pipewire.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    playerctl
    pulseaudio
    patchage
    stable.carla
    qjackctl
    alsa-utils
    alsa-lib
    alsa-plugins
    jack2
  ];
}
