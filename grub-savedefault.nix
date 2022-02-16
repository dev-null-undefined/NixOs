{ config, lib, pkgs, ... }: { boot.loader.grub = { default = "saved"; }; }
