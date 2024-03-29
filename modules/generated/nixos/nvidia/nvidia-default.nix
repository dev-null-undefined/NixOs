{pkgs, ...}: {
  environment.systemPackages = with pkgs; [nvitop];

  hardware = {
    opengl = {
      enable = true;
      extraPackages = [pkgs.vaapiIntel];
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      nvidiaSettings = true;
      modesetting.enable = true;
    };
  };

  services.xserver = {
    videoDrivers = ["nvidia"];
    dpi = 96;
  };
}
