{pkgs, ...}: {
  generated.nvidia.nvidia-default.enable = true;

  hardware.nvidia.modesetting.enable = true;
}
