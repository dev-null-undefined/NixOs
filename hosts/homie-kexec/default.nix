{
  lib,
  pkgs,
  modulesPath,
  self,
  ...
}: let
  sshKeys = import (self.outPath + "/lib/ssh-keys.nix");
in {
  imports = [
    # Produces config.system.build.kexecTree (kernel + initrd + kexec-boot script).
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];

  # Rescue env stays minimal; skip the module generator's auto-discovery so we
  # don't drag in nextcloud/jellyfin/grafana/etc.
  generated.enable = lib.mkForce false;

  # Throwaway image; trade size for build/load speed.
  netboot.squashfsCompression = "gzip -Xcompression-level 1";

  # LAN-only: bring up enp1s0 with homie's regular LAN address.
  # No WAN (enp6s0), no VLANs, no routing.
  # Hostname stays "homie-kexec" via the repo's custom hostname option.
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = false; # Trust LAN during rescue.
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "192.168.1.1";
        prefixLength = 24;
      }
    ];
  };

  # SSH via the same authorized keys as production homie.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  # Tools for the FDE migration session.
  environment.systemPackages = with pkgs; [
    cryptsetup
    btrfs-progs
    tmux
    pv
    vim
    htop
    iotop
    parted
    gptfdisk
    smartmontools
    file
    nvme-cli
  ];

  # Hardware support for homie (AMD Ryzen + NVMe).
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
    ];
    kernelModules = ["kvm-amd"];
  };

  system.stateVersion = "26.05";
}
