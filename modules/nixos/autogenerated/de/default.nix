{
  config,
  pkgs,
  lib,
  ...
}: {
  generated.de.fonts.enable = true;
  generated.de.audio.enable = true;

  generated.packages.gui.enable = lib.mkDefault true;

  hardware.bluetooth.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Proccess monitor
    zenith
    # bluetooth manager
    blueman

    # password manager
    keepassxc

    dunst
    orchis-theme
    vimix-gtk-themes

    papirus-icon-theme
    gnome-icon-theme

    # cursor themes
    phinger-cursors

    # Spell checking
    hunspell
    aspell
    gspell
    languagetool
    (aspellWithDicts (dicts: with dicts; [en en-computers en-science]))
  ];

  programs = {
    nm-applet.enable = true;

    ssh.startAgent = false;

    seahorse.enable = true;
    noisetorch.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
  };

  xdg = {
    portal.enable = true;
    mime.defaultApplications = {
      "inode/directory" = ["nemo.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
    };
  };

  services.gnome.gnome-keyring.enable = true;

  hardware.enableAllFirmware = true;
}
