{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [nvitop];

  hardware = {
    opengl.enable = true;
    nvidia = {
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver = {
    videoDrivers = ["nvidia"];
    dpi = 96;
  };
}
