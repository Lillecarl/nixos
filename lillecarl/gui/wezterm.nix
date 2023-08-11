{ config
, pkgs
, inputs
, ...
}: {
  programs.wezterm = {
    enable = true;

    extraConfig = ''
      local act = wezterm.action

      return {
        check_for_updates = false,
        hide_mouse_cursor_when_typing = false,
        color_scheme = 'Solarized (dark) (terminal.sexy)',
        hide_tab_bar_if_only_one_tab = true,
        default_prog = { '/usr/bin/env', 'xonsh' },
        font = wezterm.font_with_fallback({
          'Hack Nerd Font',
          'Hack',
          'Unifont',
        }),
        font_size = 10,
        enable_wayland = true,
        skip_close_confirmation_for_processes_named = {
          'bash',
          'sh',
          'zsh',
          'fish',
          'xonsh',
          'tmux',
          'zellij',
          'python',
          'python3',
        },
        keys = {
          {
            key = "h",
            mods = "ALT",
            action = act.ActivatePaneDirection 'Left',
          },
          {
            key = "l",
            mods = "ALT",
            action = act.ActivatePaneDirection 'Right',
          },
          {
            key = "k",
            mods = "ALT",
            action = act.ActivatePaneDirection 'Up',
          },
          {
            key = "j",
            mods = "ALT",
            action = act.ActivatePaneDirection 'Down',
          },
        },
      }
    '';
  };
}
