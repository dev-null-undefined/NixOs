{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alacritty
    kitty
  ];
}
