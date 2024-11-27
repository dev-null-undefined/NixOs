{
  pkgs,
  lib,
  ...
}: {
  generated.nvidia.nvidia-default.enable = lib.mkDefault true;

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    reverseSync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
