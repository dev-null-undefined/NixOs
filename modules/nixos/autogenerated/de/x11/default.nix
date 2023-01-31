{
  config,
  pkgs,
  lib,
  ...
}: {
  generated.de.enable = lib.mkDefault true;

  services.xserver = {
    enable = true;
    layout = "us";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
