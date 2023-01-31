{pkgs, ...}: {
  generated.nvidia.nvidia-default.enable = true;

  services.xserver.screenSection = ''
    Option         "metamodes" "1920x1080_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNC=Off}"
  '';

  hardware.nvidia.prime.sync.enable = true;
}
