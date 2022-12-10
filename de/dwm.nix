{ config, pkgs, ... }:

{
  imports = [ ../nvidia-sync.nix ./default.nix ./autorandr/autorandr.nix ];

  services.blueman.enable = true;

  security.pam.services = {
    sddm.u2fAuth = true;
#    i3lock.u2Auth = true;
  };

  services.xserver = {
    displayManager = {
      sddm = {
        enable = true;
        autoNumlock = true;
      };
      defaultSession = "none+customdwm";
    };

    windowManager = {
      session = [{
        name = "customdwm";
        start = ''
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
          sha256 = "sha256-Xrr5nusg4Z/gFFGEg9iD212ugEZSV9UaSm2ot35RMZk=";
        };
        buildInputs = old.buildInputs ++ [ pkgs.imlib2 ];
      });
    })
  ];

  programs.slock.enable = true;

  environment = {
    systemPackages = with pkgs; [
      gnome.gnome-disk-utility
      gnome.gnome-tweaks

      rofi
      acpi
      xmenu
      # no longer needed thanks to dwm patchwmname # fix problems with JDK
      pasystray
      xorg.xbacklight
      dconf
    ];
    sessionVariables.PATH = [ "/home/martin/.dwm" ];
  };

  services.dwm-status = {
    enable = true;
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
  services.gvfs.enable = true;
}
