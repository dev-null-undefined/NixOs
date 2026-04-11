{config, ...}: let
  r = config.registry;
in {
  networking.firewall = {
    allowedTCPPorts = [r.services.minecraft.port];
    allowedUDPPorts = [r.services.minecraft-voice.port];
  };
}
