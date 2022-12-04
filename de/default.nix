{ config, pkgs, ... }:

{
  imports = [ ./fonts.nix ./audio/audio.nix ];

  hardware.bluetooth.enable = true;

  hardware.bluetooth.settings.General = {
    ControllerMode = "bredr";
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

  environment.systemPackages = with pkgs; [
    dunst
    orchis-theme
    vimix-gtk-themes
    papirus-icon-theme
    gnome-icon-theme

    # Spell checking
    hunspell
    aspell
    gspell
    languagetool
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
  ];

  programs = {
    seahorse.enable = true;
    noisetorch.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
    };
  };

  xdg.mime.defaultApplications = {
    "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
  };

  services.gnome.gnome-keyring.enable = true;

  hardware.enableAllFirmware = true;
}
