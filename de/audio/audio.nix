{ pkgs, ...}:

{
  imports = [
    ./pulse.nix
  ];
  # Enable sound.
  sound.enable = true;
  environment.systemPackages = with pkgs; [
    playerctl
  ];
}
