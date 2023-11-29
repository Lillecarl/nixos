{ inputs, pkgs, lib, ... }:
let
  catppuccin-theme = builtins.readFile "${inputs.catppuccin-rofi}/basic/.local/share/rofi/themes/catppuccin-mocha.rasi";
in
{
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

  home.file.".local/share/rofi/themes/catppuccin-mocha.rasi".text = catppuccin-theme;
}
