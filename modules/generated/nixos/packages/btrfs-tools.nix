{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Compression statistics
    stable.compsize

    btrfs-progs
  ];
}
