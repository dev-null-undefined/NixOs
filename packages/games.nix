{ pkgs, ... }:

{

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = true;

  environment.systemPackages = with pkgs; [
    (pkgs.multimc.overrideAttrs (old: rec{
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
