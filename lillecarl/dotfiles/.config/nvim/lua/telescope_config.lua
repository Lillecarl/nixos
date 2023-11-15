require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      --i = {
      --  -- map actions.which_key to <C-h> (default: <C-/>)
      --  -- actions.which_key shows the mappings for your picker,
      --  -- e.g. git_{create, delete, ...}_branch for the git_branches picker
      --  ["<C-h>"] = "which_key"
      --}
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
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
  prefix = "<leader>",
})
