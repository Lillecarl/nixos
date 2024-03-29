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
        remote_kitty yes
        confirm_os_window_close 0
        scrollback_fill_enlarged_window yes
        scrollback_pager nvimpager
        notify_on_cmd_finish invisible 30
        allow_remote_control yes
        listen_on unix:@kitty
      '';

      keybindings =
        let
          vimcmd = "vim -c 'set ft=man buftype=nofile' -c '$'-";
        in
        {
          "alt+f1" = "launch --stdin-source=@last_cmd_output --type=overlay ${vimcmd}";
          "alt+f2" = "launch --stdin-source=@screen --type=overlay ${vimcmd}";
          "alt+f3" = "launch --stdin-source=@screen_scrollback --type=overlay ${vimcmd}";
          "ctrl+shift+g" = "show_last_command_output";
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
          "ctrl+shift+alt+t" = "no_op";
          "ctrl+shift+b" = "no_op";
          "ctrl+shift+delete" = "no_op";
          "ctrl+shift+k" = "no_op";
          "ctrl+shift+e" = "no_op";
          "ctrl+shift+enter" = "no_op";
          "ctrl+shift+equal" = "no_op";
          "ctrl+shift+escape" = "no_op";
          "ctrl+shift+f" = "no_op";
          "ctrl+shift+f1" = "no_op";
          "ctrl+shift+f10" = "no_op";
          "ctrl+shift+f11" = "no_op";
          "ctrl+shift+f12" = "no_op";
          "ctrl+shift+f2" = "no_op";
          "ctrl+shift+f3" = "no_op";
          "ctrl+shift+f4" = "no_op";
          "ctrl+shift+f5" = "no_op";
          "ctrl+shift+f6" = "no_op";
          "ctrl+shift+f7" = "no_op";
          "ctrl+shift+f8" = "no_op";
          "ctrl+shift+f9" = "no_op";
          "ctrl+shift+left" = "no_op";
          "ctrl+shift+minus" = "no_op";
          "ctrl+shift+n" = "launch --copy-env --type=os-window";
          "ctrl+shift+o" = "no_op";
          "ctrl+shift+q" = "no_op";
          "ctrl+shift+r" = "no_op";
          "ctrl+shift+right" = "no_op";
          "ctrl+shift+s" = "no_op";
          "ctrl+shift+t" = "no_op";
          "ctrl+shift+u" = "no_op";
          "ctrl+shift+w" = "no_op";
        };
    };
  };
}
