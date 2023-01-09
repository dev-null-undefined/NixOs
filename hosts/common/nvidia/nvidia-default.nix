{pkgs, ...}: {
  environment.systemPackages = with pkgs; [nvitop];

  services.xserver = {
    videoDrivers = ["nvidia"];
    dpi = 96;
  };
}
