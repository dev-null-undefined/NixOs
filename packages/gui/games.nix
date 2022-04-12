{ pkgs, lib, ... }:

{

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;

  boot.kernel.sysctl = { "abi.vsyscall32" = 0; };

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: [ pkgs.glxinfo ];
      withPrimus = true;
    };
  };
  programs.steam.enable = true;

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
    (polymc.overrideAttrs (old: rec {
      src = fetchFromGitHub {
        owner = "lebestnoob";
        repo = "PolyMC-Offline";
        rev = "6c2365bb83c33a6232cc36051ce2838659c888b4";
        sha256 = "sha256-3EYY4aoWGh/9BnvncKBnHDF+f1TvaR00Ydx0tw0ncN8=";
        fetchSubmodules = true;
      };
    }))
    #polymc


    vitetris
    lutris
    gnome.zenity
    stable.vulkan-tools
    stable.vulkan-headers
    stable.vulkan-loader
    stable.vulkan-tools-lunarg
  ];
}
