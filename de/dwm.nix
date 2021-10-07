
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
          sha256 = "1q3dgzd0pa5yigbg9z5gqhwkyvq5mxg98mwxxdmbmzg7jij9yz5s";
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
      gnome3.dconf
    ];
    sessionVariables.PATH = [ "/home/martin/.dwm" ];
  };

  services.dwm-status = {
    enable  = true;
    order = [ "cpu_load" "audio" "battery" "time" ];
    extraConfig = ''
      separator = "    "
      [audio]
      mute = "ﱝ"
      template = "{ICO} {VOL}%"
      icons = ["奄", "奔", "墳"]

      [battery]
      charging = ""
      discharging = ""
      no_battery = ""
      icons = ["", "", "", "", "", "", "", "", "", "", ""]

      [time]
      format = "%Y-%d-%m %H:%M"
      '';
  };

  services.gnome.gnome-keyring.enable = true;
  #services.autorandr.enable = true;
}
