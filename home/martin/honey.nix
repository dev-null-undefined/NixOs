{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      ",preferred,auto,1"
      "desc:HP Inc. HP X34 6CM14806T6,highrr,700x0,1"
      "desc:Microstep MPG321UX OLED 0x01010101,highrr,0x1440,1"
      "desc:HP Inc. HP 24fh 3CM0330W0G,preferred,3840x1440,1"
    ];
    workspace = [
      "1, monitor:desc:Microstep MPG321UX OLED 0x01010101, default:true"
      "11, monitor:desc:HP Inc. HP X34 6CM14806T6, default:true"
      "4, monitor:desc:HP Inc. HP 24fh 3CM0330W0G, default:true"
    ];
  };
}
