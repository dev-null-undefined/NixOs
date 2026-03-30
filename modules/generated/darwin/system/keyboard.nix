{
  system.keyboard = {
    enableKeyMapping = true;
    # Swap ISO § key (next to left shift) with Grave Accent/Tilde (left of 1)
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771172; # 0x700000064 - Non-US Backslash (ISO §/±)
        HIDKeyboardModifierMappingDst = 30064771125; # 0x700000035 - Grave Accent/Tilde
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771125; # 0x700000035 - Grave Accent/Tilde
        HIDKeyboardModifierMappingDst = 30064771172; # 0x700000064 - Non-US Backslash (ISO §/±)
      }
    ];
  };
}
