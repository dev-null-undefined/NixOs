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
    programs.opensnitch.enable =
      nixosConfig.generated.services.opensnitch.enable;
  };
  p10k.colors = lib.optionalAttrs nixosConfig.services.sshd.enable {
    OS_ICON_FOREGROUND = 7;
    OS_ICON_BACKGROUND = 232;
  };
}
