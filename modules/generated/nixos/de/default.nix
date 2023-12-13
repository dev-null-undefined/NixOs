{
  pkgs,
  lib,
  ...
}: {
  generated = {
    de = {
      fonts.enable = true;
      audio.enable = true;
    };

    packages.gui.enable = lib.mkDefault true;
  };

  services = {
    # Services needed for mounting USB and other removable medias by NEMO
    udisks2.enable = lib.mkDefault true;
    gvfs.enable = lib.mkDefault true;

    gnome.gnome-keyring.enable = true;
  };

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    # Proccess monitor
    stable.zenith
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
    mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["nemo.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
      };
    };
  };

  services.xserver = {
    enable = true;
    layout = "us";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };

  hardware.enableAllFirmware = true;
}
