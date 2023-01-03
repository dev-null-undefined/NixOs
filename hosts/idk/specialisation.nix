{ config, pkgs, ... }:

{
  specialisation = {
    dwm.configuration = {
      system.nixos.tags = [ "dwm" ];
      imports = [ ./de/dwm.nix ];
    };
    gnome.configuration = {
      system.nixos.tags = [ "gnome" ];
      imports = [ ./de/gnome.nix ];
    };
    i3.configuration = {
      system.nixos.tags = [ "i3" ];
      imports = [ ./de/i3.nix ];
    };
    plasma.configuration = {
      system.nixos.tags = [ "plasma" ];
      imports = [ ./de/plasma.nix ];
    };
  };
}
