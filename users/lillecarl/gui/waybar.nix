{
  lib,
  config,
  pkgs,
  nixosConfig ? null,
  ...
}:
let
  sleep = "${pkgs.coreutils-full}/bin/sleep";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swayncclient";
  bluetooth = nixosConfig.hardware.bluetooth.enable or false;
in
{
  config = lib.mkIf config.ps.gui.enable {
    home.packages = [
      pkgs.networkmanagerapplet # For nm-applet icons
    ];
    catppuccin.waybar.enable = true;

    programs.waybar = {
      enable = true;

      systemd = {
        enable = true;
        target = "graphical-session.target";
      };

      style = # scss
      ''
        * {
          font-family: "Hack Nerd Font";
          color: @text;
        }

        #waybar {
          background-color: @base;
        }
      '';

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = [
            "idle_inhibitor"
            "niri/workspaces"
          ];
          modules-center = [
            "niri/window"
          ];
          modules-right =
            [
              "niri/language"
              "backlight"
              "battery"
              "pulseaudio"
            ]
            ++ (
              if bluetooth then
                [
                  "bluetooth"
                ]
              else
                [ ]
            )
            ++ [
              "tray"
              "custom/notification"
              "clock"
            ];

          clock = {
            interval = 1;
            tooltip = true;
            format = "{:%Y-%m-%d\n %H:%M:%S}";
          };
          pulseaudio = {
            scroll-step = 1; # %, can be a float
            format = "🔊{volume}% {icon}  {format_source}";
            format-bluetooth = "{volume}% {icon}  {format_source}";
            format-bluetooth-muted = "🔇 {icon}  {format_source}";
            format-muted = "🔇 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "${lib.getExe config.programs.kitty.package} --single-instance ${lib.getExe pkgs.pulsemixer}";
            on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          backlight = {
            format = "{percent}%💡";
          };
          battery = {
            interval = 5;
            full-at = 85;
            format = "🔋{capacity}% {power}w";
          };
          bluetooth = {
            format = "  {status} ";
            format-disabled = "";
            format-connected = " {num_connections} connected";
            tooltip-format = "{controller_alias}\t{controller_address}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          };
          tray = {
            icon-size = 24;
            spacing = 5;
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec = "${swaync-client} -swb";
            on-click = "${sleep} 0.1;${swaync-client} -t -sw";
            on-click-right = "${sleep} 0.1;${swaync-client} -d -sw";
            escape = true;
          };
        };
      };
    };

    systemd.user.services.waybar = {
      Service = {
        RestartSec = "1s";
        Restart = "on-failure";
      };
    };
  };
}
