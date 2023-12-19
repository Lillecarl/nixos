{ pkgs, ... }:
{
  imports = [
    ../../common/stylix.nix
  ];
  stylix = {
    targets = {
      # Disable swaylock target since we're using Gandalf slapsh screen
      swaylock.enable = false;
    };
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };
}
