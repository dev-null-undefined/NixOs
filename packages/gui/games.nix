{ pkgs, ... }:

let
    stable = import <nixos-stable> { config = { allowUnfree = true; }; };
in {

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;

  boot.kernel.sysctl = {
      "abi.vsyscall32" = 0;
  };

  environment.systemPackages = with pkgs; [
    (stable.multimc.overrideAttrs (old: rec{
      src = fetchFromGitHub {
        owner = "AfoninZ";
        repo = "MultiMC5-Cracked";
        rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634";
        sha256 = "0nyf3gm0r3k3dbi4bd21g2lj840nkhz43pnlfjcz199y2f3zbdbl";
        fetchSubmodules = true;
      };
    })) 
    vitetris
    lutris
    gnome.zenity
    vulkan-tools
    vulkan-headers
    vulkan-loader
    vulkan-tools-lunarg
  ];
}
