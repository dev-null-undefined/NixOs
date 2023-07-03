{config, ...}: {
  services.autorandr = {
    enable = true;
    defaultTarget = "mobile";
    profiles = {
      docked = {
        fingerprint = {
          DP-0 = "00ffffffffffff0005e30227a0a70400341e0104a53c22783b1cb5a95045a4270d5054bfef00d1c081803168317c4568457c6168617c023a801871382d40582c450056502100001e000000ff004759474c434841333035303536000000fc003237473247340a202020202020000000fd003090a0a021010a20202020202001a2020327f14c0103051404131f120211903f23090707830100006d1a000002013090000000000000377f8088703814401820350056502100001e866f80a0703840403020350056502100001efe5b80a0703835403020350056502100001e2a4480a0703827403020350056502100001a0000000000000000000000000000000092";
          eDP-1-1 = "00ffffffffffff0006afed8000000000101b0104a5221378026a75a456529c270b505400000001010101010101010101010101010101ce8f80b6703888403020a50058c110000000ce8f80b670382b473020a50058c110000000000000fe0041554f0a202020202020202020000000fe004231353648414e30382e30200a0017";
        };
        config = {
          HDMI-0.enable = false;
          DP-1.enable = false;
          DP-1-1.enable = false;
          HDMI-1-1.enable = false;
          DP-0 = {
            crtc = 0;
            mode = "1920x1080";
            position = "0x0";
            rate = "144.00";
          };
          eDP-1-1 = {
            crtc = 4;
            mode = "1920x1080";
            position = "1920x0";
            rate = "144.03";
          };
        };
        hooks.postswitch = {
          post = builtins.readFile ./docked_post_switch.sh;
        };
      };
      mobile = {
        fingerprint = {
          eDP-1-1 = "00ffffffffffff0006afed8000000000101b0104a5221378026a75a456529c270b505400000001010101010101010101010101010101ce8f80b6703888403020a50058c110000000ce8f80b670382b473020a50058c110000000000000fe0041554f0a202020202020202020000000fe004231353648414e30382e30200a0017";
        };
        config = {
          HDMI-0.enable = false;
          DP-1.enable = false;
          DP-1-1.enable = false;
          HDMI-1-1.enable = false;
          DP-0.enable = false;
          eDP-1-1 = {
            crtc = 4;
            mode = "1920x1080";
            position = "0x0";
            rate = "144.03";
          };
        };
      };
    };
  };
}
