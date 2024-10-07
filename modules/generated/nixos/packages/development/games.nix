{pkgs, ...}: {
  environment.systemPackages = with pkgs; [pixelorama godot_4];
}
