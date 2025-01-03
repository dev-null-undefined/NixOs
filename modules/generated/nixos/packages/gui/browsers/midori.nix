{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    stable.midori
  ];
}
