{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Compression statistics
    compsize

    btrfs-progs
  ];
}
