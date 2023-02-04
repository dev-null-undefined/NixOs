{
  config,
  pkgs,
  ...
}: {
#  imports = [../nvidia/nvidia-sync.nix ./default.nix];

  services.xserver = {
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [kde-gtk-config];
}
