{ inputs
, pkgs
, ...
}:
let
  nerdFont = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
in
{
  stylix = {
    image = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
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

      sizes = {
        applications = 11;
        terminal = 11;
      };
    };

    cursor = {
      size = 32;
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "Catppuccin-Mocha-Dark-Cursors";
    };
  };
}
