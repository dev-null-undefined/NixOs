{lib, ...}: {
  # man pages
  documentation = {
    enable = true;

    dev.enable = true;
    doc.enable = true;

    info.enable = true;

    man = {
      enable = true;
      cache.enable = lib.mkDefault true;
    };

    # nixos.includeAllModules = lib.mkDefault true;
  };
}
