{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.carl.gui.rofi;
in
{
  options.carl.gui.rofi = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      package = pkgs.rofi-wayland;

      extraConfig = {
        modi = "run,drun,window";
        icon-theme = "Oranchelo";
        show-icons = true;
        terminal = "alacritty";
        drun-display-format = "{icon} {name}";
        location = 0;
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 🪟  Window";
        display-Network = " 󰤨  Network";
        sidebar-mode = true;
      };
    };
  };
}
