{lib, ...}: {
  p10k.colors.DIR_BACKGROUND = 141;
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # left: Dell 27" rotated portrait (NVIDIA DP)
      "desc:Dell Inc. DELL U2725QE 4DC0JF4,3840x2160@120,1120x1025,1.5,transform,3"
      # center: ASUS 27" (NVIDIA DP)
      "desc:ASUSTek COMPUTER INC PG27UCDM TALMAS004976,3840x2160@120,2560x1440,1.5"
      # right: Dell 27" (AMD iGPU)
      "desc:Dell Inc. DELL U2725QE 79C0JF4,3840x2160@120,5120x1440,1.5"
    ];
    workspace = [
      "1, monitor:desc:ASUSTek COMPUTER INC PG27UCDM TALMAS004976, default:true"
      "5, monitor:desc:Dell Inc. DELL U2725QE 4DC0JF4, default:true"
      "9, monitor:desc:Dell Inc. DELL U2725QE 79C0JF4, default:true"
    ];
  };
}
