{
  config,
  self,
  ...
}: {
  # ZFS native encryption for rpool/data.
  # The 32-byte key lives in sops; NixOS materializes it at /etc/zfs/keys/rpool.key
  # during activation (sops-nix runs as an activation script here, before systemd
  # starts any units — so the file is in place by the time zfs-import-rpool.service
  # or any /var/data mount unit fires). The dataset's keylocation property points
  # at this path, so ZFS auto-loads the key.
  sops.secrets."zfs-rpool-key" = {
    sopsFile = self.outPath + "/secrets/zfs-rpool-key";
    format = "binary";
    path = "/etc/zfs/keys/rpool.key";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # Belt-and-suspenders: explicitly tell NixOS to load the key for rpool/data
  # at pool-import time. Without this, the request-credentials path only acts
  # on the root pool (which is btrfs here). The actual key bytes come from the
  # dataset's keylocation=file:///etc/zfs/keys/rpool.key property.
  boot.zfs.requestEncryptionCredentials = ["rpool/data"];
}
