{ config, pkgs, inputs, ... }:

{
  imports = [ ../nvidia-sync.nix ./default.nix ./autorandr/autorandr.nix ];

  services.blueman.enable = true;

  security.pam.services.sddm.u2fAuth = true;

  programs = {
    i3lock = {
      enable = true;
      u2fSupport = true;
      package = pkgs.dev-null.i3lock-color;
    };
    kdeconnect = { enable = true; };
    slock = { enable = true; };
  };

  services.power-profiles-daemon.enable = true;

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
      dwm = {
        package = pkgs.dwm.overrideAttrs (old: {
          src = inputs.dwm-dev-null;
          buildInputs = old.buildInputs ++ [ pkgs.imlib2 ];
        });
        enable = true;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      gnome.gnome-disk-utility
      gnome.gnome-tweaks
      gnome.nautilus

      rofi
      ulauncher

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
