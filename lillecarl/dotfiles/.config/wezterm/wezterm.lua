local wezterm = require 'wezterm';

return {
	check_for_updates = false,
	hide_tab_bar_if_only_one_tab = true,
	font = wezterm.font_with_fallback({
		'Hack Nerd Font',
		'Hack',
		'Unifont',
	}),
	font_size = 10,
	enable_wayland = true,
}
