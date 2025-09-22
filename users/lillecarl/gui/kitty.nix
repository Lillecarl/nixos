{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    programs.kitty = {
      enable = true;

      settings = {
        # Include a git symlinked config for easier impure edits
        include = "linked.conf";
        # Borders
        active_border_color = "#74c7ec";
        inactive_border_color = "#585b70";
        border_width = 1.0;
        draw_minimal_borders = "no";

        inactive_text_alpha = 0.7;

        update_check_interval = 0;
        confirm_os_window_close = 0;
        scrollback_fill_enlarged_window = "yes";
        scrollback_pager = "less";
        notify_on_cmd_finish = "invisible 15 notify";
        allow_remote_control = "yes";
        listen_on = "unix:@kitty";
        scrollback_lines = 25000;
        tab_bar_align = "center";
        tab_bar_edge = "top";
        tab_bar_min_tabs = 2;
        tab_bar_style = "separator";
        tab_separator = " |";
        tab_activity_symbol = "🔔";
      };

      keybindings = {
        "ctrl+tab" = "next_tab";
        "ctrl+shift+tab" = "previous_tab";
        "ctrl+shift+0" = "change_font_size all 0";
        "ctrl+shift+1" = "change_font_size all -1.0";
        "ctrl+shift+2" = "change_font_size all +1.0";
        "ctrl+shift+3" = "no_op";
        "ctrl+shift+4" = "no_op";
        "ctrl+shift+5" = "no_op";
        "ctrl+shift+6" = "no_op";
        "ctrl+shift+7" = "no_op";
        "ctrl+shift+8" = "no_op";
        "ctrl+shift+9" = "no_op";
      };
    };
  };
}
