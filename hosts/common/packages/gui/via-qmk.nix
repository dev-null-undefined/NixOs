{ pkgs, ... }:

let udev-packages = with pkgs; [ vial via ];
in {
  services.udev.packages = udev-packages;
  environment.systemPackages = with pkgs;
    [ qmk qmk-udev-rules ] ++ udev-packages;
}
