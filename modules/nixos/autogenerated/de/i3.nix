{
  config,
  pkgs,
  ...
}: {
#  imports = [../nvidia/nvidia-sync.nix ./default.nix];
  services.xserver = {
    desktopManager = {xterm.enable = false;};

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        rofi # application launcher most people use
        i3lock # default i3 screen locker
        i3status-rust
      ];
    };
  };
  services.autorandr.enable = true;
}
