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
        window_close_confirmation = 'NeverPrompt',
        hide_mouse_cursor_when_typing = false,
        color_scheme = 'Catppuccin Mocha',
        hide_tab_bar_if_only_one_tab = true,
        default_prog = { '${pkgs.fish}/bin/fish' },
        font = wezterm.font_with_fallback({
          'Hack Nerd Font',
          'Hack',
          'Unifont',
        }),
        font_size = 10,
        enable_wayland = true,
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
