{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.kitty;
in
{
  options.carl.gui.kitty = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      extraConfig = ''
        include linked.conf
        update_check_interval 0
        confirm_os_window_close 0
        scrollback_fill_enlarged_window yes
        scrollback_pager nvimpager
        notify_on_cmd_finish invisible 30
        allow_remote_control yes
        listen_on unix:@kitty
        scrollback_lines 25000
        tab_bar_edge top
        tab_bar_style separator
        tab_bar_align center
        tab_bar_separator " |"
        tab_bar_min_tabs 1
        tab_activity_symbol 🔔
      '';

      keybindings =
        let
          vimcmd = "vim -c 'set ft=man buftype=nofile' -c '$'-";
        in
        {
          "alt+f1" = "launch --stdin-source=@last_cmd_output --type=overlay ${vimcmd}";
          "alt+f2" = "launch --stdin-source=@screen --type=overlay ${vimcmd}";
          "alt+f3" = "launch --stdin-source=@screen_scrollback --type=overlay ${vimcmd}";
          "ctrl+shift+," = "no_op";
          "ctrl+shift+." = "no_op";
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
          "ctrl+shift+[" = "no_op";
          "ctrl+shift+]" = "no_op";
          "ctrl+shift+`" = "no_op";
          "ctrl+shift+a>1" = "no_op";
          "ctrl+shift+a>2" = "no_op";
          "ctrl+shift+a>l" = "no_op";
          "ctrl+shift+alt+t" = "set_tab_title";
          "ctrl+shift+b" = "no_op";
          "ctrl+shift+delete" = "no_op";
          "ctrl+shift+e" = "no_op";
          "ctrl+shift+enter" = "new_window_with_cwd";
          "ctrl+shift+equal" = "no_op";
          "ctrl+shift+escape" = "kitty_shell";
          "ctrl+shift+f" = "no_op";
          "ctrl+shift+f1" = "no_op";
          "ctrl+shift+f10" = "no_op";
          "ctrl+shift+f11" = "no_op";
          "ctrl+shift+f12" = "no_op";
          "ctrl+shift+f2" = "no_op";
          "ctrl+shift+f3" = "no_op";
          "ctrl+shift+f4" = "no_op";
          "ctrl+shift+f5" = "load_config_file";
          "ctrl+shift+f6" = "no_op";
          "ctrl+shift+f7" = "no_op";
          "ctrl+shift+f8" = "no_op";
          "ctrl+shift+f9" = "no_op";
          "ctrl+shift+g" = "no_op";
          "ctrl+shift+j" = "next_tab";
          "ctrl+shift+k" = "previous_tab";
          "ctrl+shift+left" = "previous_tab";
          "ctrl+shift+minus" = "no_op";
          "ctrl+shift+n" = "new_os_window_with_cwd";
          "ctrl+shift+o" = "no_op";
          "ctrl+shift+q" = "no_op";
          "ctrl+shift+r" = "no_op";
          "ctrl+shift+right" = "next_tab";
          "ctrl+shift+s" = "no_op";
          "ctrl+shift+t" = "new_tab";
          "ctrl+shift+u" = "no_op";
          "ctrl+shift+w" = "no_op";
        };
    };
  };
}
