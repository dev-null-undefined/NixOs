{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    midori
  ];
}
