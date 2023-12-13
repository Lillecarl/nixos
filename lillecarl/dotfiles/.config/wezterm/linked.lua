local wezterm = require('wezterm');
local act = wezterm.action

return {
  check_for_updates = false,
  window_close_confirmation = 'NeverPrompt',
  hide_mouse_cursor_when_typing = false,
  hide_tab_bar_if_only_one_tab = true,
  term = "wezterm",
  enable_wayland = true,
  set_environment_variables = {
    WSLENV = 'TERMINFO_DIRS',
  },
  disable_default_key_bindings = true,
  keys = {
    {
      key = "x",
      mods = "CTRL|SHIFT",
      action = act.ActivateCopyMode,
    },
  },
}
