{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gparted
    # gparted dependecies
    exfatprogs
    dosfstools
    f2fs-tools
    gpart
    mtools
    ntfs3g
    e2fsprogs
    lvm2
    cryptsetup
  ];
}
