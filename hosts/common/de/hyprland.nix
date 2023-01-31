{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [../nvidia/nvidia-sync.nix ./fonts.nix ./audio/audio.nix ../packages/gui/default.nix];

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-utils

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

  hardware.enableAllFirmware = true;
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

    hyprland = {
      package = pkgs.hyprland-nvidia;
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
    };

    wshowkeys.enable = true;
    light.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    getty.autologinUser = "martin";
  };

  security.pam.services.swaylock = {u2fAuth = true;};

  environment.sessionVariables = {
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "SDL_VIDEODRIVER" = "wayland";
    "QT_QPA_PLATFORM" = "wayland";
    "XDG_CURRENT_DESKTOP" = "sway";
    "XDG_SESSION_DESKTOP" = "sway";
  };
}
