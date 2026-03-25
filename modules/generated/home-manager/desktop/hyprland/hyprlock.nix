{...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 2;
        hide_cursor = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 5;
          noise = 1.17e-2;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          size = "400, 60";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgb(191724)";
          inner_color = "rgb(1f1d2e)";
          font_color = "rgb(e0def4)";
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          check_color = "rgb(eb6f92)";
          fail_color = "rgb(31748f)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # Time
        {
          text = "cmd[update:1000] date +\"%H:%M\"";
          color = "rgb(e0def4)";
          font_size = 90;
          font_family = "Inter";
          position = "0, 150";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          text = "cmd[update:1000] date +\"%d.%m.%Y\"";
          color = "rgb(e0def4)";
          font_size = 24;
          font_family = "Inter";
          position = "0, 70";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
