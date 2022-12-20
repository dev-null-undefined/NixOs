{ config, pkgs, ... }:

{
  imports = [ ../nvidia-offload.nix ./default.nix ];

  hardware.pulseaudio.enable = false;
  services = {

    switcherooControl.enable = true;

    xserver = {
      desktopManager.gnome.enable = true;

      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
      };
    };
  };

  environment.systemPackages = (with pkgs; [
    gnome.gnome-tweaks

    # A app-indicator for GNOME desktops wireless headsets
    headset-charge-indicator

    # Xorg like screen share
    xdg-desktop-portal-gnome

    # vitals extension dependencies
    libgtop
    lm_sensors
  ]) ++ (with pkgs.gnomeExtensions; [
    sound-output-device-chooser
    vitals
    dash-to-panel
    removable-drive-menu
    gsconnect
    appindicator
    unite
    custom-hot-corners-extended
    animation-tweaks
  ]);

  xdg.portal.wlr.enable = true;

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  services.dbus.packages = with pkgs; [ gnome2.GConf ];

}
