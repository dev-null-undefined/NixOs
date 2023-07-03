{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    shfmt
  ];
}
