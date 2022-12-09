{ pkgs, ... }:

let
  version = "12.3.1";
  lang = "en";
in { environment.systemPackages = with pkgs; [ dev-null.mathematica ]; }
