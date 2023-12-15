local wk = require('which-key')
local toggleterm = require("toggleterm")

toggleterm.setup({
})

-- Allow leaving terminal mode with <C-\>
wk.register({
  ["<C-\\>"] = { [[<C-\><C-N>]], "Terminal unfocus" },
  ["<S-Esc>"] = { [[<C-\><C-N>]], "Terminal unfocus" },
},
{
  mode = "t",
})

wk.register({
  ["t"] = {
    name = "terminal",
    ["t"] = { [[<cmd>ToggleTerm<cr>]], "Toggle terminal" },
    ["n"] = { [[<cmd>ToggleTerm direction=horizontal<cr>]], "New terminal (horizontal)" },
    ["v"] = { [[<cmd>ToggleTerm direction=vertical<cr>]], "New terminal (vertical)" },
    ["f"] = { [[<cmd>ToggleTerm direction=float<cr>]], "New terminal (float)" },
  },
},
{
  mode = "n",
  prefix = "<leader>",
})

-- Disable line numbers and start insert mode when opening a terminal
vim.api.nvim_create_autocmd('TermOpen', {
  once = true,
  callback = function(args)
    vim.o.number = false
    vim.o.relativenumber = false
    vim.cmd('startinsert')
  end,
})

