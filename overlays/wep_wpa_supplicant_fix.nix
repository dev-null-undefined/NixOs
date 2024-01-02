(self: super: {
  wpa_supplicant = super.wpa_supplicant.overrideAttrs (oldAttrs: rec {
    extraConfig =
      oldAttrs.extraConfig
      + ''
        CONFIG_WEP=y
      '';
  });
})
