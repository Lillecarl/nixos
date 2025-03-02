{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin-nix.homeManagerModules.catppuccin
  ];

  config = lib.mkIf config.ps.gui.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "blue";
    };
    catppuccin.helix.enable = true;
    catppuccin.helix.useItalics = true;

    gtk = {
      enable = true;
      cursorTheme = lib.mkForce {
        name = "Catppuccin-Mocha-Blue";
        package = lib.mkForce pkgs.catppuccin-cursors.mochaBlue;
      };
      #iconTheme = {
      #  name = "Adwaita";
      #  package = pkgs.gnome.adwaita-icon-theme;
      #};
      theme = {
        name = lib.mkForce "adw-gtk3-dark";
      };
    };

    qt = {
      enable = true;
      style.name = "kvantum";
      platformTheme.name = "kvantum";
    };

    home.pointerCursor.name = lib.mkForce "Catppuccin-Mocha-Blue";
    home.pointerCursor.package = lib.mkForce pkgs.catppuccin-cursors.mochaBlue;

    home.file.".icons/Catppuccin-Mocha-Blue".source =
      lib.mkForce "${config.home.pointerCursor.package}/share/icons/catppuccin-mocha-blue-cursors";
    xdg.dataFile."icons/Catppuccin-Mocha-Blue".source =
      lib.mkForce "${config.home.pointerCursor.package}/share/icons/catppuccin-mocha-blue-cursors";

    xdg.configFile."qt5ct/colors/Catppuccin-Mocha.conf".source =
      "${inputs.catppuccin-qt5ct}/themes/Catppuccin-Mocha.conf";
    xdg.configFile."qt5ct/qt5ct.conf".text = ''
      [Appearance]
      color_scheme_path=/home/lillecarl/.config/qt5ct/colors/Catppuccin-Mocha.conf
      custom_palette=true
      icon_theme=Adwaita
      standard_dialogs=default
      style=Fusion

      [Fonts]
      fixed="Hack Nerd Font,9,-1,5,50,0,0,0,0,0"
      general="Sans Serif,9,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3

      [Troubleshooting]
      force_raster_widgets=1
      ignored_applications=@Invalid()
    '';
  };
}
