{ pkgs, lib, ... }:
let
  modifier = "Mod4";
in
{
  wayland.windowManager.sway = {
    enable = true;

    xwayland = true;

    swaynag.enable = true;


    config = {
      gaps = {
        inner = 12;
        outer = 0;

        smartBorders = "no_gaps";
        smartGaps = true;
      };
      startup = [
        { command = "${pkgs.systemd}/bin/systemctl --user restart hyprland-session.target"; }
        { command = "${pkgs.firefox}/bin/firefox"; }
        { command = "${pkgs.wezterm}/bin/wezterm-gui"; }
      ];

      inherit modifier;

      keybindings = lib.mkOptionDefault {
        "${modifier}+q" = "${pkgs.wezterm}/bin/wezterm-gui";
        "${modifier}+c" = "kill";
        "${modifier}+r" = "${pkgs.rofi-wayland}/bin/rofi -show drun";
      };

      input = {
        "*" = {
          xkb_variant = "eu";
          natural_scroll = "enabled";
        };
      };

      focus = {
        mouseWarping = true;
        newWindow = "smart";
      };

      bars = [ ];
    };

    systemd = {
      enable = true;
      xdgAutostart = true;
    };
  };
}
