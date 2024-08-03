{pkgs, ...}: {
  environment.systemPackages = with pkgs; [nvitop];

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [vaapiIntel nvidia-vaapi-driver];
      driSupport32Bit = true;
    };
    nvidia = {
      nvidiaSettings = true;
    };
  };

  services.xserver = {
    videoDrivers = ["nvidia" "intel"];
    dpi = 96;
  };
}
