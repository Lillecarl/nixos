{ config
, pkgs
, inputs
, ...
}: {
  programs.wezterm = {
    enable = true;

    extraConfig = ''
      return {
        check_for_updates = false,
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
      }
    '';
  };
}
