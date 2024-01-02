{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    verilog
    verible
  ];
}
