{lib, ...}: {
  p10k.colors.DIR_BACKGROUND = 141;
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      ",preferred,auto,1"
      "desc:HP Inc. HP X34 6CM14806T6,3440x1440@165,0x0,1.25"
      "desc:AOC 27G2G4 GYGLCHA305056,1920x1080@144,2752x672,1,transform,1"
      "desc:Microstep MPG321UX OLED 0x01010101,3840x2160@240,192x1152,1.5"
      "desc:HP Inc. HP 24fh 3CM0330W0G,preferred,3840x1440,1"
    ];
    workspace = [
      "1, monitor:desc:Microstep MPG321UX OLED 0x01010101, default:true"
      "11, monitor:desc:HP Inc. HP X34 6CM14806T6, default:true"
      "9, monitor:desc:AOC 27G2G4 GYGLCHA305056, default:true"
      # "4, monitor:desc:HP Inc. HP 24fh 3CM0330W0G, default:true"
    ];
  };
}
