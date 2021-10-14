{ pkgs, ... }:

let
    stable = import <nixos-stable> { config = { allowUnfree = true; }; };
in {

  imports = [
    ./discord.nix
    ./games.nix
    ./jetbrains.nix
    ./teamviewer.nix
    ./vscode.nix
    ./mathematica.nix
    ./virt-manager.nix
  ];

  environment.systemPackages = with pkgs; [
      # ======= GUI programms ======
      obs-studio
      ardour easyeffects
      spotify
      libreoffice
      firefox brave chromium
      copyq lxappearance wireshark
      gimp-with-plugins vlc blender stable.shotcut
      font-manager ark
      dolphin gnome.nautilus pcmanfm
      gparted flameshot pavucontrol arandr
      insomnia alacritty kitty stable.mysql-workbench

      # Spell checking
      hunspell
      hunspellDicts.en-us hunspellDicts.cs-cz

      papirus-icon-theme

  ];
}
