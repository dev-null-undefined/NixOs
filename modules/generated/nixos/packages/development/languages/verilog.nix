{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    iverilog
    verible
  ];
}
