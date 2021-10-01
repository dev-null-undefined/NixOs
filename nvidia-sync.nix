{ pkgs, ... }:

{
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    dpi = 96;
  };
  hardware.nvidia.prime = {
    sync.enable = true;
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
}
