{ inputs
, pkgs
, self
, ...
}:
let
  hyprctl = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl";

  cursorSettings = {
    name = "macOS-BigSur";
    size = 24;
    package = pkgs.apple-cursor;
  };
in
{
  gtk = {
    cursorTheme = cursorSettings // {
      gtk.enable = true;
      x11.enable = true;
    };
  };

  home.pointerCursor = cursorSettings;

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    extraConfig = ''
      monitor=,preferred,auto,auto
      
      exec-once = ${pkgs.waybar}/bin/waybar & ${pkgs.hyprpaper}/bin/hyprpaper
      
      env = XCURSOR_SIZE,24
      env = XCURSOR_THEME,macOS-BigSur
      
      input {
          kb_layout = us,se
          kb_variant =
          kb_model =
          kb_options = caps:escape, grp:alt_shift_toggle
          kb_rules =
      
          follow_mouse = 1
      
          touchpad {
              natural_scroll = true
              disable_while_typing = 1
          }
      
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }
      
      general {
          gaps_in = 5
          gaps_out = 5
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
      
          layout = dwindle
      }
      
      decoration {
          rounding = 5
      
          blur {
              enabled = true
              size = 3
              passes = 1
          }
      
          drop_shadow = true
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }
      
      animations {
          enabled = true
      
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
      
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }
      
      dwindle {
          pseudotile = true 
          preserve_split = true
      }
      
      master {
          new_is_master = true
      }
      
      gestures {
          workspace_swipe = true
      }
      
      $mainMod = SUPER
      
      bind = $mainMod, Q, exec, ${pkgs.wezterm}/bin/wezterm-gui
      bind = Ctrl_L Alt_L, delete, exec, ${pkgs.swaylock}/bin/swaylock -i ${self}/resources/lockscreen.jpg --color 000000
      bindl = , code:121, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindl = , code:122, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
      bindl = , code:123, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
      bindl = , code:198, exec, ${pkgs.mictoggle}
      bindl = , code:232, exec, ${pkgs.light}/bin/light -U 10
      bindl = , code:233, exec, ${pkgs.light}/bin/light -A 10
      bind = $mainMod, C, killactive,
      bind = Ctrl_L Alt_L, end, exit,
      bind = $mainMod, F, togglefloating,active
      bind = $mainMod, M, fullscreen,1
      bind = $mainMod, E, exec, dolphin
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, R, exec, ${pkgs.wofi}/bin/wofi --show drun
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, I, togglesplit, # dwindle
      # Switch to US layout
      bind = ALT SHIFT, E, exec, hyprctl switchxkblayout at-translated-set-2-keyboard 0
      bind = $mainMod, E, exec, hyprctl switchxkblayout at-translated-set-2-keyboard 0
      # Switch to SE layout
      bind = ALT SHIFT, S, exec, hyprctl switchxkblayout at-translated-set-2-keyboard 1
      bind = $mainMod, S, exec, hyprctl switchxkblayout at-translated-set-2-keyboard 1
      
      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Move focus with mainMod + hjlk
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d

      # Resize windows with mainMod + shift + arrow keys
      binde = $mainMod SHIFT, left, resizeactive, -10 0
      binde = $mainMod SHIFT, right, resizeactive, 10 0
      binde = $mainMod SHIFT, up, resizeactive, 0 -10
      binde = $mainMod SHIFT, down, resizeactive, 0 10
      
      # Resize windows with mainMod + shift + arrow keys
      binde = $mainMod SHIFT, h, resizeactive, -10 0
      binde = $mainMod SHIFT, l, resizeactive, 10 0
      binde = $mainMod SHIFT, k, resizeactive, 0 -10
      binde = $mainMod SHIFT, j, resizeactive, 0 10
      
      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      
      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      
      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      
      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';
  };
}
