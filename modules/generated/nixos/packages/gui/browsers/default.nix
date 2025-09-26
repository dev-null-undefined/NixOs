{lib, ...}: {
  generated.packages.gui.browsers =
    lib.attrsets.genAttrs
    ["firefox" "chromium" "zen"]
    (_: {enable = lib.mkDefault true;});
}
