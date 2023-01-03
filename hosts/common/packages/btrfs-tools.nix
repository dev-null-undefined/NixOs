{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Compression statistics
    compsize

    btrfs-progs
  ];
}
