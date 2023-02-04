{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alacritty
    master.kitty
  ];
}
