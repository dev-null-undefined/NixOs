{pkgs, ...}: {
  services.opensnitch.enable = true;
  environment.systemPackages = with pkgs; [
    opensnitch-ui
  ];
}
