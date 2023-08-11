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

    #style = ''
    #  * {
    #    font-family: Hack Nerd Font;
    #  }
    #'';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        #output = [
        #  "eDP-1"
        #  "HDMI-A-1"
        #];
        modules-left = [ "wlr/taskbar" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "battery" "pulseaudio" "clock" ];

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
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
        battery = {
          full-at = 85;
          format = "🔋{capacity}% {power}w";
        };
      };
    };
  };
}
