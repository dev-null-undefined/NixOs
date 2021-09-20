
{ config, pkgs, ... }:

{
  imports = [ ../nvidia-sync.nix ];
  services.xserver = {
    enable = true;

    displayManager = {
        sddm.enable = true;
        defaultSession = "customdwm";
    };

    windowManager = {
      session = [{ 
        name = "customdwm";
        start =
          ''
          /home/martin/.dwm/autostart &
          waitPID=$!
          '';
      }]; 
      dwm.enable = true;
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      dwm = prev.dwm.overrideAttrs (old: { 
        src = /home/martin/Git/siduck76/chadwm/chadwm;
        buildInputs = old.buildInputs ++ [ pkgs.imlib2 ];
        preBuild = "make clean";
      });
    })
  ];
  
  environment = {
    systemPackages = with pkgs; [
      rofi
      acpi
      slock # locker
      xmenu
      wmname # fix problems with JDK 
      xorg.xbacklight
    ];
    sessionVariables.PATH = [ "/home/martin/.dwm" ];
  };

  services.autorandr.enable = true;
}
