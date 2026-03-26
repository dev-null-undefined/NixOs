{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [inputs.admin-helper-scripts.packages.${pkgs.stdenv.hostPlatform.system}.default];
}
