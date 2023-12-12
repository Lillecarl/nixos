require('telescope').setup{
  defaults = {
    mappings = {
    }
  },
  pickers = {
  },
  extensions = {
  }
}

--  Keybinds
local telescope_builtin = require('telescope.builtin')
local wk = require("which-key")

wk.register({
  f = {
    name = "Telescope",
    f = { telescope_builtin.find_files, "Find File" },
    g = { telescope_builtin.live_grep,  "Grep" },
    b = { telescope_builtin.buffers,    "Buffers" },
    h = { telescope_builtin.help_tags,  "Help" },
  },
},
{
  mode = "n",
  prefix = vim.g.mapleader,
})
