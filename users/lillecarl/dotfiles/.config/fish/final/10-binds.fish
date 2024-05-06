#! /usr/bin/env fish

# bind ctrl+a to beginning of buffer
bind -M insert \ca beginning-of-buffer
bind -M visual \ca beginning-of-buffer

# bind ctrl+e to end of buffer
bind -M insert \ce end-of-buffer
bind -M visual \ce end-of-buffer

# bind alt+l to complete whatever fish is suggesting
bind -M insert \el forward-char

# bind ctrl+shift+e to edit command buffer
bind -M insert \e\[101\;6u edit_command_buffer
bind -M visual \e\[101\;6u edit_command_buffer

# bind / to atuin search with cursor position kept
bind -M visual / '__call_keep_cursor_pos "_atuin_search"'

# bind ctrl+r to atuin search with cursor position kept
bind -M insert \cR '__call_keep_cursor_pos "_atuin_search"'
bind -M visual \cR '__call_keep_cursor_pos "_atuin_search"'

# bind ctrl+r to atuin session search with cursor position kept
bind -M insert \e\[A '__call_keep_cursor_pos "_atuin_bind_up"'
bind -M visual \e\[A '__call_keep_cursor_pos "_atuin_bind_up"'

# bind ctrl+shift+d to scroll down
bind -M insert \e\[100\;6u scrolldown
bind -M visual \e\[100\;6u scrolldown

# bind ctrl+z to interactive zoxide
bind -M insert \cZ '__call_keep_cursor_pos "zi"'
bind -M visual \cZ '__call_keep_cursor_pos "zi"'
