{lib, ...}: {
  p10k.colors.DIR_BACKGROUND = 141;
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      ",preferred,auto,1"
      # top center: MSI 32" OLED
      "desc:Microstep MPG321UX OLED 0x01010101,3840x2160@120,4480x0,1.5"
      # bottom left: Dell 27"
      "desc:Dell Inc. DELL U2725QE 4DC0JF4,3840x2160@120,0x1440,1"
      # bottom center: ASUS 27"
      "desc:ASUSTek COMPUTER INC PG27UCDM TALMAS004976,3840x2160@120,3840x1440,1"
      # bottom right: Dell 27"
      "desc:Dell Inc. DELL U2725QE 79C0JF4,3840x2160@120,7680x1440,1"
    ];
    workspace = [
      "1, monitor:desc:Microstep MPG321UX OLED 0x01010101, default:true"
      "2, monitor:desc:ASUSTek COMPUTER INC PG27UCDM TALMAS004976, default:true"
      "3, monitor:desc:Dell Inc. DELL U2725QE 4DC0JF4, default:true"
      "4, monitor:desc:Dell Inc. DELL U2725QE 79C0JF4, default:true"
    ];
  };
}
