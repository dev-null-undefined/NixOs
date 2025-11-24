{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      ",preferred,auto,1"
      "desc:BNQ BenQ PD3205U 59P01340019,preferred,0x0,1.5,transform,1"
      "desc:BNQ BenQ PD3205U GBP00096019,preferred,1440x590,1.5"
      "desc:Samsung Display Corp. 0x4196,preferred,4000x750,2"
    ];
    workspace = [
      "11, monitor:desc:BNQ BenQ PD3205U 59P01340019, default:true"
      "1, monitor:desc:BNQ BenQ PD3205U GBP00096019, default:true"
      "9, monitor:desc:Samsung Display Corp. 0x4196, default:true"
    ];
  };
}
