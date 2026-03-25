{lib, ...}: {
  generated.home.cli.ssh = {
    work.enable = lib.mkDefault true;
    config.enable = lib.mkDefault true;
    # self-hosted.enable = lib.mkDefault true; moved out
    # school.enable = lib.mkDefault true; # no longer a student :[
  };
}
