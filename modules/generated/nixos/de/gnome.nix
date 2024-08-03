{
  pkgs,
  lib,
  ...
}: {
  system.nixos.tags = ["gnome"];
  generated = {
    de.enable = true;
    # nvidia.nvidia-offload.enable = lib.mkDefault true;
    nvidia.nvidia-sync.enable = lib.mkDefault true;
  };

  hardware.pulseaudio.enable = false;

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  xdg.portal.wlr.enable = true;

  services = {
    xserver = {
      desktopManager.gnome.enable = true;

      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
      };
    };

    udev.packages = with pkgs; [gnome.gnome-settings-daemon];
    dbus.packages = with pkgs; [gnome2.GConf];
  };
  environment = {
    systemPackages =
      (with pkgs; [
        gnome.gnome-tweaks

        # A app-indicator for GNOME desktops wireless headsets
        headset-charge-indicator

        # Xorg like screen share
        xdg-desktop-portal-gnome

        # vitals extension dependencies
        libgtop
        lm_sensors

        #valent
      ])
      ++ (with pkgs.gnomeExtensions; [
        sound-output-device-chooser
        vitals
        dash-to-panel
        removable-drive-menu
        gsconnect
        appindicator
        unite
        custom-hot-corners-extended
        valent # kde implementation for gnome
        #animation-tweaks
        #paperwm
      ]);

    sessionVariables = {
      GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
      ]);
      QT_QPA_PLATFORM = "xcb";
    };
  };
}
