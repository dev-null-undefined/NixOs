{pkgs, ...}: {
#  imports = [./nvidia-default.nix];

  hardware.nvidia.modesetting.enable = true;
}
