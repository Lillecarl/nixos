-- use space as leader key
vim.g.mapleader = " "

local wk = require('which-key')

wk.register({
  ["<tab>"] = {
    name = "tab",
    ["l"]   =       { "<cmd>tablast<cr>", "Last Tab" },
    ["f"]   =       { "<cmd>tabfirst<cr>", "First Tab" },
    ["]"]   =       { "<cmd>tabnext<cr>", "Next Tab" },
    ["d"]   =       { "<cmd>tabclose<cr>", "Close Tab" },
    ["["]   =       { "<cmd>tabprevious<cr>", "Previous Tab" },
    ["<tab>"] = { "<cmd>tabnew<cr>", "New Tab" },
  },
},
{
  mode = "n",
  prefix = "<leader>",
})
--[[
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
--]]
if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.o.guifont = "Hack Nerd Font:h11"
  vim.g.neovide_cursor_animate_in_insert_mode = false
end

-- Setup nvim-tree
local nvim_tree_api = require('nvim-tree.api')

local function nvim_tree_attach(bufnr)
  local function opts(desc)
    return {
      desc = "nvim-tree: " .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true
    }
  end

  -- default mappings
  nvim_tree_api.config.mappings.default_on_attach(bufnr)

  -- custom mappings (Within nvim-tree buffer)
  vim.keymap.set('n', '<C-t>', nvim_tree_api.tree.toggle, {})
  vim.keymap.set('n', '?',     nvim_tree_api.tree.toggle_help, opts('Help'))
end

require("nvim-tree").setup({
  on_attach = nvim_tree_attach,
})

-- Setup nvim-tree bindings
vim.keymap.set('n', '<C-t>', nvim_tree_api.tree.toggle, {})


vim.cmd [[
" Allow leaving terminal mode with <C-hjkl>
:tnoremap <C-h> <C-\><C-N><C-w>h
:tnoremap <C-j> <C-\><C-N><C-w>j
:tnoremap <C-k> <C-\><C-N><C-w>k
:tnoremap <C-l> <C-\><C-N><C-w>l
" Show a line down column 81 to indicate the 80 column limit
:set colorcolumn=81

" List all custom mappings in a new buffer
function! s:ShowMaps()
  let old_reg = getreg("a")          " save the current content of register a
  let old_reg_type = getregtype("a") " save the type of the register as well
try
  redir @a                           " redirect output to register a
  " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
  silent map | call feedkeys("\<CR>")
  redir END                          " end output redirection
  vnew                               " new buffer in vertical window
  put a                              " put content of register
  " Sort on 4th character column which is the key(s)
  %!sort -k1.4,1.4
finally                              " Execute even if exception is raised
  call setreg("a", old_reg, old_reg_type) " restore register a
endtry
endfunction
com! ShowMaps call s:ShowMaps()      " Enable :ShowMaps to call the function

nnoremap \m :ShowMaps<CR>            " Map keys to call the function
]]

-- Disable line numbers and start insert mode when opening a terminal
vim.api.nvim_create_autocmd('TermOpen', {
  once = true,
  callback = function(args)
    vim.cmd [[
    :set nonumber
    startinsert
    ]]
  end,
})

-- indent blanklines
require("ibl").setup()
