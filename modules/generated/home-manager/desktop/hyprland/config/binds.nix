{lib, ...}: let
  mappings = with lib.lists;
    (map (n: {
      keybind = toString n;
      number = toString n;
    }) (range 1 9))
    ++ [
      {
        keybind = toString 0;
        number = toString 10;
      }
    ]
    ++ (map (n: {
      keybind = "F${toString n}";
      number = toString (10 + n);
    }) (range 1 12));

  workspace_control =
    lib.lists.concatMap (bind: [
      # Switch workspaces with mainMod + [0-9] and move the workspace to current focused monitor
      "$mainMod CTRL, ${bind.keybind}, moveworkspacetomonitor, ${bind.number} current"
      "$mainMod CTRL, ${bind.keybind}, workspace, ${bind.number}"

      # Switch workspaces with mainMod + [0-9]
      "bind = $mainMod, ${bind.keybind}, workspace, ${bind.number}"

      # Move active window to a workspace with mainMod + Alt + [0-9] but stay at current workspace
      "$mainMod CTRL SHIFT, ${bind.keybind}, movetoworkspacesilent, ${bind.number}"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "bind = $mainMod SHIFT, ${bind.keybind}, movetoworkspace, ${bind.number}"
    ])
    mappings;
in {
  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    "$mainMod" = "SUPER";

    bind =
      [
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        # LayOut managment
        "$mainMod, P, pseudo,"
        # dwindle
        "$mainMod, J, togglesplit, # dwindle"

        # Window managment key binds
        "$mainMod,     Q, killactive,"
        "$mainMod,     F, fullscreen,"
        "$mainMod, Space, togglefloating,"

        # Move focus with mainMod + arrow keys
        "$mainMod, left,  movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up,    movefocus, u"
        "$mainMod, down,  movefocus, d"

        # Move to next workspace (numericly)
        "$mainMod CTRL, left,  workspace, m-1"
        "$mainMod CTRL, right, workspace, m+1"

        # Move active window and focust to next workspace (numericly)
        "$mainMod SHIFT CTRL, left,  movetoworkspace, m-1"
        "$mainMod SHIFT CTRL, right, movetoworkspace, m+1"

        # Change focust to previous workspace
        "$mainMod, tab,        workspace, previous"

        # Change to next window
        "ALT      , Tab,             cyclenext,          # change focus to another window"
        "ALT      , Tab,             bringactivetotop,   # bring it to the top"
        "ALT SHIFT, Tab,             cyclenext,    prev"
        "ALT SHIFT, Tab,             bringactivetotop,   # bring it to the top"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, m+1"
        "$mainMod, mouse_up,   workspace, m-1"

        # Basic apps
        "$mainMod, Return, exec, kitty"
        "$mainMod,      M, exit,"
        "$mainMod,      E, exec, nemo"
        "$mainMod,      C, exec, fuzzel"
        "CTRL SHIFT,    A, exec, copyq toggle"
        "CTRL SHIFT,    N, exec, swaync-client -t -sw"

        "$mainMod, L, exec, swaylock"
        "CTRL SHIFT, Escape, exec, wlogout"
        ", Print, exec, grimblast copy area"

        # Hyprspace overview plugin
        "CTRL, Tab,   overview:toggle,"
      ]
      ++ workspace_control;

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      # mouse:272 = left  click
      # mouse:273 = right click
      "$mainMod,       mouse:272, movewindow"
      "$mainMod SHIFT, mouse:272, resizewindow"
      "$mainMod,       mouse:273, resizewindow"
    ];

    binde = [
      ### Audio
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@      5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@      5%-"
      ", XF86AudioMute,        exec, wpctl set-mute   @DEFAULT_AUDIO_SINK@   toggle"
      ", XF86AudioMicMute,     exec, wpctl set-mute   @DEFAULT_AUDIO_SOURCE@ toggle"

      # backlight
      ", XF86MonBrightnessUp,   exec, light -A 1.6"
      ", XF86MonBrightnessDown, exec, light -T 0.6"
    ];

    bindl = [
      # media controls
      ", XF86AudioPlay,        exec, playerctl play-pause"
      ", XF86AudioPrev,        exec, playerctl previous"
      ", XF86AudioNext,        exec, playerctl next"
    ];

    binds = {
      workspace_back_and_forth = true;
      allow_workspace_cycles = true;
    };
    gestures = {
      workspace_swipe = true;
    };
  };
}
