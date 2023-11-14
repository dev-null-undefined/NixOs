{
  lib,
  pkgs,
}: ''


  # See https://wiki.hyprland.org/Configuring/Keywords/ for more

  # Execute favorite apps at launch
  exec-once = copyq
  exec-once = swaync
  exec-once = waybar
  exec-once = pasystray
  exec-once = batsignal -c 10
  exec-once = configure-gtk
  exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  exec-once = blueman-applet
  exec-once = sleep 1 && syncthingtray
  exec-once = ${pkgs.libsForQt5.polkit-kde-agent.outPath}/libexec/polkit-kde-authentication-agent-1
  exec-once = ${pkgs.galaxy-buds-client.outPath}/bin/GalaxyBudsClient

  # exec-once = swaylock --grace -1 # Enable this if you autostart hyprland without window manager

  # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
  input {

      kb_layout = us, cz
      kb_variant = ,qwerty
      kb_model =
      kb_options = grp:rctrl_toggle
      kb_rules =

      follow_mouse = 1

      touchpad {
          natural_scroll = yes
      }

      sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
  }

  general {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 5
      gaps_out = 5
      border_size = 1
      col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
      col.inactive_border = rgba(595959aa)

      layout = dwindle
  }

  decoration {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      rounding = 5
      blur {
        size = 3
        passes = 1
      }

      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
  }

  animations {
      enabled = yes

      # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = myBezier, 0.05, 0.9, 0.1, 1.05

      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
  }

  dwindle {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      no_gaps_when_only = true
      pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = yes # you probably want this
  }

  master {
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      new_is_master = true
  }

  gestures {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = true
  }

  binds {
      # See https://wiki.hyprland.org/Configuring/Variables/#binds
      workspace_back_and_forth = true
      allow_workspace_cycles = true
  }


  misc {
    disable_hyprland_logo = true
    enable_swallow = true
    swallow_regex = ^(kitty)$
  }

  # See https://wiki.hyprland.org/Configuring/Keywords/ for more
  $mainMod = SUPER

  # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
  # LayOut managment
  bind = $mainMod, P, pseudo, # dwindle
  bind = $mainMod, J, togglesplit, # dwindle

  # Window managment key binds
  bind = $mainMod,     Q, killactive,
  bind = $mainMod,     F, fullscreen,
  bind = $mainMod, Space, togglefloating,

  # Basic apps
  bind = $mainMod, Return, exec, kitty
  bind = $mainMod,      M, exit,
  bind = $mainMod,      E, exec, nemo
  bind = $mainMod,      C, exec, wofi --show drun
  bind = CTRL SHIFT,    A, exec, copyq toggle
  bind = CTRL SHIFT,    N, exec, swaync-client -t -sw

  bind = $mainMod, L, exec, swaylock
  bind = CTRL SHIFT, Escape, exec, wlogout
  bind = , Print, exec, grimblast copy area

  # Move focus with mainMod + arrow keys
  bind = $mainMod, left,  movefocus, l
  bind = $mainMod, right, movefocus, r
  bind = $mainMod, up,    movefocus, u
  bind = $mainMod, down,  movefocus, d

  # Move to next workspace (numericly)
  bind = $mainMod CTRL, left,  workspace, m-1
  bind = $mainMod CTRL, right, workspace, m+1

  # Move active window and focust to next workspace (numericly)
  bind = $mainMod SHIFT CTRL, left,  movetoworkspace, m-1
  bind = $mainMod SHIFT CTRL, right, movetoworkspace, m+1


  # Change focust to previous workspace
  bind = $mainMod, tab,        workspace, previous

  # Change to next window
  bind = ALT, Tab,             cyclenext,          # change focus to another window
  bind = ALT, Tab,             bringactivetotop,   # bring it to the top


  # Scroll through existing workspaces with mainMod + scroll
  bind = $mainMod, mouse_down, workspace, m+1
  bind = $mainMod, mouse_up,   workspace, m-1

  ### Audio
  binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@      5%+
  binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@      5%-
  bindl = , XF86AudioMute,        exec, wpctl set-mute   @DEFAULT_AUDIO_SINK@   toggle
  bindl = , XF86AudioMicMute,     exec, wpctl set-mute   @DEFAULT_AUDIO_SOURCE@ toggle

  # media controls
  bindl = , XF86AudioPlay,        exec, playerctl play-pause
  bindl = , XF86AudioPrev,        exec, playerctl previous
  bindl = , XF86AudioNext,        exec, playerctl next


  # backlight
  bindle = , XF86MonBrightnessUp,   exec, light -A 1.6
  bindle = , XF86MonBrightnessDown, exec, light -T 0.6

  #BEGIN AUTOGENERATED
  ${
    let
      mappings = with lib.lists;
        (map (
          n: {
            keybind = toString n;
            number = toString n;
          }
        ) (range 1 9))
        ++ [
          {
            keybind = toString 0;
            number = toString 10;
          }
        ]
        ++ (map (
          n: {
            keybind = "F${toString n}";
            number = toString (10 + n);
          }
        ) (range 1 12));
    in
      builtins.concatStringsSep "\n" (map (
          bind: ''
            # Switch workspaces with mainMod + [0-9] and move the workspace to current focused monitor
            bind = $mainMod CTRL, ${bind.keybind}, moveworkspacetomonitor, ${bind.number} current
            bind = $mainMod CTRL, ${bind.keybind}, workspace, ${bind.number}

            # Switch workspaces with mainMod + [0-9]
            bind = $mainMod, ${bind.keybind}, workspace, ${bind.number}

            # Move active window to a workspace with mainMod + Alt + [0-9] but stay at current workspace
            bind = $mainMod CTRL SHIFT, ${bind.keybind}, movetoworkspacesilent, ${bind.number}

            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            bind = $mainMod SHIFT, ${bind.keybind}, movetoworkspace, ${bind.number}
          ''
        )
        mappings)
  }
  #END AUTOGENERATED

  # Move/resize windows with mainMod + LMB/RMB and dragging
  # mouse:272 = left  click
  # mouse:273 = right click
  bindm = $mainMod,       mouse:272, movewindow
  bindm = $mainMod SHIFT, mouse:272, resizewindow
  bindm = $mainMod,       mouse:273, resizewindow


  # Firefox stuff
  # make Firefox PiP window floating and sticky
  windowrulev2 = float, title:^(Picture-in-Picture)$
  windowrulev2 = pin, title:^(Picture-in-Picture)$

  # throw sharing indicators away
  windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

  # Spotify
  windowrulev2 = tile, class:^(Spotify)$

  # copyq
  windowrulev2 = float, class:^(com\.github\.hluk\.copyq)$, title:^(.* — CopyQ)$

  # █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
  # ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
  windowrule = float, file_progress
  windowrule = float, confirm
  windowrule = float, dialog
  windowrule = float, download
  windowrule = float, notification
  windowrule = float, error
  windowrule = float, splash
  windowrule = float, confirmreset
  windowrule = float, title:Open File
  windowrule = float, title:branchdialog
  windowrule = float, Rofi
  windowrule = animation none,Rofi
  windowrule = float, pavucontrol-qt
  windowrule = float, pavucontrol
  windowrule = float, file-roller
  windowrule = fullscreen, wlogout
  windowrule = float, title:wlogout
  windowrule = fullscreen, title:wlogout
  windowrule = float, title:^(Media viewer)$
  windowrule = float, title:^(Volume Control)$
  windowrule = size 800 600, title:^(Volume Control)$
  windowrule = move 75 44%, title:^(Volume Control)$

  # Jetbrains products

  # Attempt to make jetbrains work number 1
  # windowrulev2 = float,floating:0,class:^(jetbrains-.*),title:^(win.*)
  #windowrulev2 = float,class:^(jetbrains-.*),title:^(Welcome to.*)
  #windowrulev2 = center,class:^(jetbrains-.*)
  # windowrulev2 = forceinput,class:^(jetbrains-.*)
  # windowrulev2 = windowdance,class:^(jetbrains-.*) # allows IDE to move child windows

  # Attempt to make jetbrains work number 2
  windowrulev2=windowdance,class:^(jetbrains-.*)$
  # search dialog
  windowrulev2=dimaround,class:^(jetbrains-.*)$,floating:1,title:^(?!win)
  windowrulev2=center,class:^(jetbrains-.*)$,floating:1,title:^(?!win)
  # autocomplete & menus
  windowrulev2=noanim,class:^(jetbrains-.*)$,title:^(win.*)$
  windowrulev2=noinitialfocus,class:^(jetbrains-.*)$,title:^(win.*)$
  windowrulev2=rounding 0,class:^(jetbrains-.*)$,title:^(win.*)$
''
