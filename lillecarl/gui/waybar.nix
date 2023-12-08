{ inputs
, pkgs
, keyboardName
, bluetooth
, ...
}:
let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  sleep = "${pkgs.coreutils-full}/bin/sleep";
  swaync = "${pkgs.swaynotificationcenter}/bin/swaync";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swayncclient";
in
{
  home.packages = [
    pkgs.networkmanagerapplet # For nm-applet icons
  ];

  programs.waybar = {
    enable = true;

    package = pkgs.waybar;

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
          "custom/weather"
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
          format = "🔊{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "🔇 {icon} {format_source}";
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
        "custom/weather" = {
          exec = "${pkgs.curl}/bin/curl -L \"wttr.in/Stockholm?format=%f+%p\"";
          format = "{}";
          interval = 3600;
          #signal = 1;
        };
        "hyprland/language" = {
          format = " KB: {} ";
          format-en = "EN";
          format-sv = "SE";
          format-eu = "EU";
          keyboard-name = keyboardName;
          on-click = "${hyprctl} switchxkblayout ${keyboardName} next";
        };
        "hyprland/submap" = {
          format = ", {}";
          max-length = 10;
          tooltip = false;
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
}
