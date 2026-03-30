{...}: {
  imports = builtins.attrValues (import ../modules/home-manager/default.nix);
  generated.home = {
    enable = true;
  };
}
