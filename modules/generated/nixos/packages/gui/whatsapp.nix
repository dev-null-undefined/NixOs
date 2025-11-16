{pkgs, ...}: {
  environment.systemPackages = with pkgs; [wasistlos];
}
