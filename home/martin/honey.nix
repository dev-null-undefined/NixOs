{lib, ...}: {
  p10k.colors.DIR_BACKGROUND = 141;
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      ",preferred,auto,1"
      # top center: MSI 32" OLED (NVIDIA HDMI)
      "desc:Microstep MPG321UX OLED 0x01010101,3840x2160@120,2560x0,1.5"
      # bottom left: Dell 27" (NVIDIA DP)
      "desc:Dell Inc. DELL U2725QE 4DC0JF4,3840x2160@120,0x1440,1.5"
      # bottom center: ASUS 27" (NVIDIA DP)
      "desc:ASUSTek COMPUTER INC PG27UCDM TALMAS004976,3840x2160@120,2560x1440,1.5"
      # bottom right: Dell 27" (AMD iGPU)
      "desc:Dell Inc. DELL U2725QE 79C0JF4,3840x2160@120,5120x1440,1.5"
    ];
    workspace = [
      "11, monitor:desc:Microstep MPG321UX OLED 0x01010101, default:true"
      "1, monitor:desc:ASUSTek COMPUTER INC PG27UCDM TALMAS004976, default:true"
      "5, monitor:desc:Dell Inc. DELL U2725QE 4DC0JF4, default:true"
      "9, monitor:desc:Dell Inc. DELL U2725QE 79C0JF4, default:true"
    ];
  };
}
