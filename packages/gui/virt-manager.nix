{ pkgs,... }:

let
    stable = import <nixos-stable> { config = { allowUnfree = true; }; };
in {
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ stable.virt-manager ];
}
