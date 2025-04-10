{pkgs, ...}: {
  boot.kernel.sysctl = {"abi.vsyscall32" = 0;};

  programs = {
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [pkgs.glxinfo];
      };
    };
    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # We will remember you multimc <3
    #(multimc.overrideAttrs (old: rec{
    #  src = fetchFromGitHub {
    #    owner = "AfoninZ";
    #    repo = "MultiMC5-Cracked";
    #    rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634";
    #    sha256 = "0nyf3gm0r3k3dbi4bd21g2lj840nkhz43pnlfjcz199y2f3zbdbl";
    #    fetchSubmodules = true;
    #  };
    #}))
    #(master.polymc.overrideAttrs (old: rec {
    #  src = fetchFromGitHub {
    #    owner = "dev-null-undefined";
    #    repo = "PolyMC";
    #    rev = "a9717e5d3ac379fd46eedac86655b31c831a7dd7";
    #    sha256 = "sha256-Ji/Xa+jv0LEGsKttat9heyaSPCgZTYpVc0ZOA4evpVQ=";
    #    fetchSubmodules = true;
    #  };
    #}))
    glxinfo

    prismlauncher

    wineWowPackages.stable
    wine
    winetricks

    vitetris

    stable.lutris
    zenity
    vulkan-tools
    vulkan-headers
    vulkan-loader
    vulkan-tools-lunarg

    sway # For running league of legends since it's broken on hyprland :D
    dmenu
  ];
}
