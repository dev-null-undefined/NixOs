{pkgs, ...}: {
  programs.bcc.enable = true;

  environment.systemPackages = with pkgs; [
    bpfmon
    bpftrace
    bpftools
  ];
}
