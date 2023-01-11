{pkgs, ...}: {
  imports = [./nvidia-default.nix];

  services.xserver.screenSection = ''
    Option         "metamodes" "1920x1080_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNC=Off}"
  '';

  hardware.nvidia.prime.sync.enable = true;
}
