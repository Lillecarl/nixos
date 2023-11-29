{ inputs, pkgs, ... }:
let
  cursorSettings = {
    name = "Catppuccin-Macchiato-Pink";
    size = 30;
    package = pkgs.catppuccin-cursors.macchiatoPink;
  };
  #colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  nerdFont = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
in
{
  stylix = {
    image = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    targets = {
      # Disable swaylock target since we're using Gandalf
      swaylock.enable = false;
    };
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = nerdFont;
        name = "Hack Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  gtk = {
    enable = true;

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
}
