{
  config,
  pkgs,
  ...
}: {

  generated.nvidia.nvidia-sync.enable = true;
  generated.de.enable = true;

  services.xserver = {
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [kde-gtk-config];
}
