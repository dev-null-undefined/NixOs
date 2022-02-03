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
    # We will remember you multimc <3
    #(stable.multimc.overrideAttrs (old: rec{
    #  src = fetchFromGitHub {
    #    owner = "AfoninZ";
    #    repo = "MultiMC5-Cracked";
    #    rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634";
    #    sha256 = "0nyf3gm0r3k3dbi4bd21g2lj840nkhz43pnlfjcz199y2f3zbdbl";
    #    fetchSubmodules = true;
    #  };
    #})) 
    (polymc.overrideAttrs (old: rec{
      src = fetchFromGitHub {
        owner = "lebestnoob";
        repo = "PolyMC-Offline";
        rev = "dcb9e5c153dfcac3d56f7266a6a9dadbdcb26e86";
        sha256 = "sha256-8OYIw+IIWxfmtWgD7Ft64PfiOkdFzQ0GD09ifgdQwfQ=";
        fetchSubmodules = true;
      };
      patches = [ ];
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
