# Enable VAAPI hardware transcoding for Jellyfin on the AMD Raphael iGPU.
# Without this, transcoding 4K HDR HEVC remuxes saturates the CPU and HLS
# segments never reach the Xbox client in time.
{
  config,
  pkgs,
  lib,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  users.users.jellyfin.extraGroups = ["render" "video"];
}
