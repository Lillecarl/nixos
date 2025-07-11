{
  pkgs,
  lib,
  inputs,
  config,
  nixosConfig,
  ...
}:
let
  spawnWrapper = toString (
    pkgs.writeScript "niri-spawn-wrapper" # fish
      ''
        #! ${lib.getExe pkgs.fish}
        if test -S /tmp/.X11-unix/X0
          set --export DISPLAY :0
        end

        if test -S /run/user/1000/wayland-1
          set --export WAYLAND_DISPLAY wayland-1
        end

        # Run args as command
        $argv
      ''
  );
  clipHistRofi = toString (
    pkgs.writeScript "cliphistrofi" # fish
      ''
        #! ${lib.getExe pkgs.fish}
        cliphist list | rofi -dmenu -i -matching fuzzy -p History | cliphist decode | wl-copy -n
      ''
  );
in
{
  imports = [
    inputs.niri.homeModules.niri
  ];

  config = lib.mkIf config.ps.gui.enable {
    programs.niri = {
      enable = true;

      package =
        if (lib.isDerivation (nixosConfig.programs.niri.package ? null)) then
          nixosConfig.programs.niri.package
        else
          pkgs.niri;

      settings = {
        spawn-at-startup = [
          # Start niri-session.target
          {
            command = [
              "systemctl"
              "--user"
              "start"
              "${
                if ((config.systemd.user.targets.niri-session or null) != null) then
                  "niri-session.target"
                else
                  throw "niri-session.target doesn't exist"
              }"
            ];
          }
          # Activate home-manager profile once niri has started, this has the
          # side-effect to relaunch all services that have failed if niri
          # was stopped and units like waybar, avizo, swaync has failed.
          {
            command = [
              "sh"
              "-c"
              "${config.xdg.stateHome}/nix/profiles/home-manager/activate"
            ];
          }
          # Restart app-blueman@autostart.service since it doesn't fail when
          # niri dies
          {
            command = [
              "systemctl"
              "--user"
              "restart"
              "app-blueman@autostart.service"
            ];
          }
          # Spawn xwayland-sattelite inside niri
          {
            command = [
              spawnWrapper
              (lib.getExe inputs.niri.packages.x86_64-linux.xwayland-satellite-unstable)
            ];
          }
          # Spawn Firefox
          {
            command = [
              spawnWrapper
              (lib.getExe config.programs.firefox.package)
            ];
          }
          # Spawn Kitty
          {
            command = [
              spawnWrapper
              (lib.getExe config.programs.kitty.package)
            ];
          }
          # Set display output to displayport
          {
            command = [
              spawnWrapper
              (lib.getExe pkgs.ddcutil)
              "--model=XWU-CBA"
              "setvcp"
              "0x60"
              "0x0f"
            ];
          }
        ];
        layer-rules = [
          {
            matches = [
              {
                namespace = "^wallpaper$";
              }
            ];
            place-within-backdrop = true;
          }
        ];
        input = {
          warp-mouse-to-focus.enable = true;
          focus-follows-mouse.enable = false;

          keyboard.xkb.layout = "eu,se";
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
          mouse = {
            accel-profile = "flat";
          };
          trackpoint = { };
          tablet = {
            map-to-output = "eDP-1";
          };
          touch = {
            map-to-output = "eDP-1";
          };
        };

        outputs =
          let
            inherit (nixosConfig.networking) hostName;
          in
          if hostName == "shitbox" then
            {
              # Right Huawei
              DP-1 = {
                mode = {
                  width = 2560;
                  height = 1440;
                  refresh = 164.802;
                };
                position = {
                  x = 1080;
                  y = 240;
                };
              };
              # Left BENQ
              DP-2 = {
                mode = {
                  width = 1920;
                  height = 1080;
                  refresh = 143.996;
                };
                position = {
                  x = 0;
                  y = 0;
                };
                transform.rotation = 90;
              };
            }
          else if hostName == "nub" then
            let
              OfficeMon = {
                #mode = {
                #  height = 1200;
                #  width = 1920;
                #  refresh = 60;
                #};
                position = {
                  x = -780;
                  y = -1440;
                };
              };
            in
            {
              # Laptop display
              eDP-1 = {
                mode = {
                  width = 1920;
                  height = 1200;
                  refresh = 60.003;
                };
                position = {
                  x = 0;
                  y = 0;
                };
                scale = 1.0;
              };
              # Office display (port 1)
              DP-1 = OfficeMon;
              # Office display (port 2)
              DP-2 = OfficeMon;
              # Home display (Middle Huawei)
              HDMI-A-2 = {
                mode = {
                  width = 2560;
                  height = 1440;
                  refresh = 119.998;
                };
                position = {
                  x = -320;
                  y = -1440;
                };
              };
            }
          else
            throw "Unknown hostname, can't configure niri outputs";

        layout = {
          background-color = "transparent";
          focus-ring = {
            enable = true;
            width = 2;
            active = {
              color = "#7fc8ff";
            };
            inactive = {
              color = "#505050";
            };
          };

          border = {
            enable = false;
          };

          preset-column-widths = [
            { proportion = 1.0 / 3.0; }
            { proportion = 1.0 / 2.0; }
            { proportion = 2.0 / 3.0; }
          ];

          default-column-width = {
            proportion = 1.0 / 2.0;
          };

          gaps = 2;

          center-focused-column = "never";
        };

        prefer-no-csd = true;

        window-rules = [
          {
            geometry-corner-radius =
              let
                px = 10.0;
              in
              {
                bottom-left = px;
                bottom-right = px;
                top-left = px;
                top-right = px;
              };
            clip-to-geometry = true;
          }
        ];

        binds = with config.lib.niri.actions; {
          "Mod+Shift+Slash".action = show-hotkey-overlay;
          "Mod+T".action.spawn = [ "kitty" ];
          "Mod+D".action.spawn = [
            spawnWrapper
            "rofi"
            "-show"
            "drun"
          ];
          "Alt+Tab".action.spawn = [
            spawnWrapper
            "rofi"
            "-show"
            "window"
          ];
          "Mod+Ctrl+F".action.spawn = [ "firefox" ];
          "Ctrl+Alt+Delete".action.spawn = [ "swaylock" ];
          "Mod+V".action.spawn = [
            spawnWrapper
            clipHistRofi
          ];

          "XF86AudioRaiseVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1+"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1-"
          ];
          "XF86AudioMute".action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
          "XF86AudioMicMute".action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "lightctl"
            "down"
          ];
          "XF86MonBrightnessUp".action.spawn = [
            "lightctl"
            "up"
          ];

          "Mod+O" = {
            repeat = false;
            action.toggle-overview = [ ];
          };

          "Mod+Q".action.close-window = [ ];

          "Mod+Left".action.focus-column-left = [ ];
          "Mod+Down".action.focus-window-down = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+Right".action.focus-column-right = [ ];
          "Mod+H".action.focus-column-left = [ ];
          "Mod+L".action.focus-column-right = [ ];
          "Mod+J".action.focus-window-down = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+U".action.focus-workspace-down = [ ];
          "Mod+I".action.focus-workspace-up = [ ];

          "Mod+Ctrl+Left".action.move-column-left = [ ];
          "Mod+Ctrl+Down".action.move-window-down = [ ];
          "Mod+Ctrl+Up".action.move-window-up = [ ];
          "Mod+Ctrl+Right".action.move-column-right = [ ];
          "Mod+Ctrl+H".action.move-column-left = [ ];
          "Mod+Ctrl+L".action.move-column-right = [ ];
          "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = [ ];
          "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = [ ];
          "Mod+Tab".action.focus-workspace-previous = [ ];

          "Mod+Home".action.focus-column-first = [ ];
          "Mod+End".action.focus-column-last = [ ];
          "Mod+Ctrl+Home".action.move-column-to-first = [ ];
          "Mod+Ctrl+End".action.move-column-to-last = [ ];

          "Mod+Shift+Left".action.focus-monitor-left = [ ];
          "Mod+Shift+Down".action.focus-monitor-down = [ ];
          "Mod+Shift+Up".action.focus-monitor-up = [ ];
          "Mod+Shift+Right".action.focus-monitor-right = [ ];
          "Mod+Shift+H".action.focus-monitor-left = [ ];
          "Mod+Shift+J".action.focus-monitor-down = [ ];
          "Mod+Shift+K".action.focus-monitor-up = [ ];
          "Mod+Shift+L".action.focus-monitor-right = [ ];

          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

          "Mod+1".action.focus-workspace = [ 1 ];
          "Mod+2".action.focus-workspace = [ 2 ];
          "Mod+3".action.focus-workspace = [ 3 ];
          "Mod+4".action.focus-workspace = [ 4 ];
          "Mod+5".action.focus-workspace = [ 5 ];
          "Mod+6".action.focus-workspace = [ 6 ];
          "Mod+7".action.focus-workspace = [ 7 ];
          "Mod+8".action.focus-workspace = [ 8 ];
          "Mod+9".action.focus-workspace = [ 9 ];
          "Mod+Ctrl+1".action.move-column-to-workspace = [ 1 ];
          "Mod+Ctrl+2".action.move-column-to-workspace = [ 2 ];
          "Mod+Ctrl+3".action.move-column-to-workspace = [ 3 ];
          "Mod+Ctrl+4".action.move-column-to-workspace = [ 4 ];
          "Mod+Ctrl+5".action.move-column-to-workspace = [ 5 ];
          "Mod+Ctrl+6".action.move-column-to-workspace = [ 6 ];
          "Mod+Ctrl+7".action.move-column-to-workspace = [ 7 ];
          "Mod+Ctrl+8".action.move-column-to-workspace = [ 8 ];
          "Mod+Ctrl+9".action.move-column-to-workspace = [ 9 ];

          "Mod+Comma".action.consume-window-into-column = [ ];
          "Mod+Period".action.expel-window-from-column = [ ];

          "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
          "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

          "Mod+R".action.switch-preset-column-width = [ ];
          "Mod+F".action.maximize-column = [ ];
          "Mod+Shift+F".action.fullscreen-window = [ ];
          "Mod+C".action.center-column = [ ];

          "Mod+Space".action.switch-layout = [ "next" ];

          "Print".action.screenshot = [ ];
          "Ctrl+Print".action.screenshot-screen = [ ];
          "Alt+Print".action.screenshot-window = [ ];

          "Mod+Shift+E".action.quit = [ ];
          "Mod+Shift+P".action.power-off-monitors = [ ];
        };
      };
    };

    systemd.user.targets = {
      niri-session = {
        Unit = {
          X-Name = "niri-session.target";
          Description = "Target reached when niri Wayland compositor is running";

          # The following is copied from $nirisrc/resources/niri.service
          BindsTo = [ "graphical-session.target" ];
          Before = [
            "graphical-session.target"
            "xdg-desktop-autostart.target"
          ];
          Wants = [
            "graphical-session-pre.target"
            "xdg-desktop-autostart.target"
          ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };
  };
}
