{
  nixosConfig,
  lib,
  ...
}: {
  imports = builtins.attrValues (import ../modules/home-manager/default.nix);
  generated.home = {
    desktop = {
      hyprland.enable = lib.mkDefault nixosConfig.generated.de.hyprland.enable;
      sway.enable = lib.mkDefault nixosConfig.generated.de.sway.enable;
    };
    programs.enable = lib.mkDefault nixosConfig.generated.de.enable;
    programs.opensnitch.enable = nixosConfig.generated.services.opensnitch.enable;
  };
}
