local wk = require('which-key')

require("toggleterm").setup({
})

-- Allow leaving terminal mode with <C-\>
wk.register({
  --["<C-h>"] = { [[<C-\><C-N><C-w>h]], "Terminal Left" },
  --["<C-j>"] = { [[<C-\><C-N><C-w>j]], "Terminal Down" },
  --["<C-k>"] = { [[<C-\><C-N><C-w>k]], "Terminal Up" },
  --["<C-l>"] = { [[<C-\><C-N><C-w>l]], "Terminal Right" },
  ["<C-\\>"] = { [[<C-\><C-N>]], "Terminal unfocus" },
},
{
  mode = "t",
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

