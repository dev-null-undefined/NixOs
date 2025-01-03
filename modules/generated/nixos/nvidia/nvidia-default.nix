{pkgs, ...}: {
  environment.systemPackages = with pkgs; [nvitop];

  hardware = {
    opengl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # vaapiIntel
        nvidia-vaapi-driver
      ];
    };
    nvidia = {nvidiaSettings = true;};
  };

  services.xserver = {
    videoDrivers = ["nvidia" "modesetting"];
    dpi = 96;
  };
}
