{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [nvitop];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # vaapiIntel
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      nvidiaSettings = true;
      open = lib.mkDefault false;
    };
  };

  services.xserver = {
    videoDrivers = ["nvidia" "modesetting"];
    dpi = 96;
  };
}
