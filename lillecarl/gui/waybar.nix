{ inputs
, pkgs
, ...
}:
let
  hyprctl = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl";
in
{
  programs.waybar = {
    enable = true;

    package = pkgs.waybar-hyprland;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    style = builtins.readFile ./waybar.css;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        output = [
          "eDP-1"
        ];
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "hyprland/language" "battery" "pulseaudio" "clock" ];

        clock = {
          interval = 1;
          tooltip = true;
          format = "{:%Y-%m-%d\n %H:%M:%S}";
        };

        pulseaudio = {
          scroll-step = 1; # %, can be a float
          format = "🔊{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
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
        battery = {
          interval = 5;
          full-at = 85;
          format = "🔋{capacity}% {power}w";
        };
        "hyprland/language" = {
          format = "KB: {}";
          format-en = "🇺🇸";
          format-se = "🇸🇪";
          keyboard-name = "at-translated-set-2-keyboard";
          on-click = "${hyprctl} switchxkblayout at-translated-set-2-keyboard next";
        };
      };
    };
  };
}
