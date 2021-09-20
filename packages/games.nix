{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
   (pkgs.multimc.overrideAttrs (oldAttrs: rec{
      src = fetchFromGitHub {
        owner = "AfoninZ";
        repo = "MultiMC5-Cracked";
        rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634";
        sha256 = "0nyf3gm0r3k3dbi4bd21g2lj840nkhz43pnlfjcz199y2f3zbdbl";
        fetchSubmodules = true;
      };
    })) 
    vitetris
  ];
}
