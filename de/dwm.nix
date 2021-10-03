
{ config, pkgs, ... }:

{
  imports = [ 
    ../nvidia-sync.nix
    ./default.nix
   ];
  services.xserver = {
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
        src = pkgs.fetchFromGitHub {
          owner = "ThreshMain";
          repo = "dwm-flexipatch";
          rev = "master";
          sha256 = "0xjcj3y98yq0jdcc0chbkqdbk7k83ipd2hlldv42dqzmq7p0g2vj";
        };
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

  #services.autorandr.enable = true;
}
