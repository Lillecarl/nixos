{ inputs, pkgs, ... }:
let
  cursorSettings = {
    name = "Catppuccin-Macchiato-Pink";
    size = 30;
    package = pkgs.catppuccin-cursors.macchiatoPink;
  };
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  theme = (inputs.nix-colors.lib.contrib { inherit pkgs; }).gtkThemeFromScheme { scheme = colorScheme; };
in
{
  inherit colorScheme;

  home.sessionVariables = {
    XCURSOR_SIZE = cursorSettings.size;
    XCURSOR_THEME = cursorSettings.name;
  };

  gtk = {
    enable = true;

    theme = {
      name = theme.name;
      package = theme;
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
