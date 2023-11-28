{ inputs, pkgs, ... }:
let
  cursorSettings = {
    name = "Catppuccin-Macchiato-Pink";
    size = 24;
    package = pkgs.catppuccin-cursors.macchiatoPink;
  };
in
{
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Compact-Pink-dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };

    cursorTheme = cursorSettings;
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  home.pointerCursor = cursorSettings // {
    gtk.enable = true;
    x11.enable = true;
  };
}
