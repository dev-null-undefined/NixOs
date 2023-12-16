{lib, ...}: {
  generated.packages.gui.browsers =
    lib.attrsets.genAttrs
    ["firefox" "chromium"]
    (_: {enable = lib.mkDefault true;});
}
