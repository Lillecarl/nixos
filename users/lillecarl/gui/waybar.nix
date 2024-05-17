{ pkgs
, config
, lib
, nixosConfig ? null
, ...
}:
let
  cfg = config.carl.gui.waybar;
  hyprCfg = config.carl.gui.hyprland;
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  sleep = "${pkgs.coreutils-full}/bin/sleep";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swayncclient";
  bluetooth = nixosConfig.hardware.bluetooth.enable or false;
in
{
  options.carl.gui.waybar = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.networkmanagerapplet # For nm-applet icons
    ];

    stylix.targets.waybar = {
      enable = true;
      enableCenterBackColors = true;
      enableLeftBackColors = true;
      enableRightBackColors = true;
    };
    programs.waybar = {
      enable = true;

      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = [
            "idle_inhibitor"
            "hyprland/workspaces"
            "hyprland/language"
            "hyprland/submap"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "custom/nixos-update"
            "backlight"
            "battery"
            "pulseaudio"
          ]
          ++ (if bluetooth then
            [
              "bluetooth"
            ] else [ ])
          ++
          [
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
              default = [ "" "" "" ];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
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
          "hyprland/language" = {
            format = " KB: {} ";
            format-en = "EN";
            format-sv = "SE";
            format-eu = "EU";
            keyboard-name = hyprCfg.keyboardName;
            on-click = "${hyprctl} switchxkblayout ${hyprCfg.keyboardName} next";
          };
          "hyprland/submap" = {
            format = ", {}";
            max-length = 10;
            tooltip = false;
          };
          "custom/nixos-update" =
            let
              cmd = "date --date=@$(curl 'https://prometheus.nixos.org/api/v1/query?query=channel_update_time%7Bchannel%3D%22nixos-unstable%22%7D' | jq -r '.data.result[0].value[1]') -u '+%m-%dT%H'";
            in
            {
              tooltip = false;
              exec = cmd;
              on-click = cmd;
              interval = 3600;
              format = "{}";
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
  };
}
