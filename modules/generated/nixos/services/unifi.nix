{pkgs, ...}: {
  # nixpkgs forces explicit package pins for stateVersion < 24.11 to prevent
  # silent mongo-5 → mongo-7 jumps that would corrupt existing on-disk data.
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
    openFirewall = true;
    initialJavaHeapSize = 1024;
    maximumJavaHeapSize = 1024;
  };
}
