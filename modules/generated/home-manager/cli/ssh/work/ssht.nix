{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [inputs.ssht.packages.${pkgs.stdenv.hostPlatform.system}.default];
}
