{ pkgs, ... }:

{

  environment.systemPackages = with pkgs;
    [ ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [ epkgs.vterm ])) ];
}
