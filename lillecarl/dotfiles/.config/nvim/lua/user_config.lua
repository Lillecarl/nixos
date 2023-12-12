-- use space as leader key
vim.g.mapleader = " "

local wk = require('which-key')

-- Tabs
wk.register({
  ["<tab>"] = {
    name = "tab",
    ["l"]     = { "<cmd>tablast<cr>", "Last Tab" },
    ["f"]     = { "<cmd>tabfirst<cr>", "First Tab" },
    ["]"]     = { "<cmd>tabnext<cr>", "Next Tab" },
    ["d"]     = { "<cmd>tabclose<cr>", "Close Tab" },
    ["["]     = { "<cmd>tabprevious<cr>", "Previous Tab" },
    ["<tab>"] = { "<cmd>tabnew<cr>", "New Tab" },
  },
},
{
  mode = "n",
  prefix = "<leader>",
})
-- Clipboard
wk.register({
  ["y"] = {
    name = "yank",
    ["y"]     = { '"+y',    "Copy (cb)" },
    ["p"]     = { '"+p',    "Paste (cb)" },
    ["P"]     = { '"+P',    "Paste before (cb)" },
  },
},
{ mode = "v" })
wk.register({
    ["Y"]     = { '"+yg_',  "Copy" },
    ["y"]     = { '"+y',    "Copy (cb)" },
    ["p"]     = { '"+p',    "Paste (cb)" },
    ["P"]     = { '"+P',    "Paste before (cb)" },
},
{
  mode = "n",
  prefix = "<leader>",
})

-- No mouse thanks
vim.o.mouse = false
-- Show line numbers relative to cursor
vim.o.number = true
vim.o.relativenumber = true
-- utf-8 as default encoding
encoding="utf-8"
-- Ignore case when searching lower-case
vim.o.ignorecase = true
-- Respect case when searching mixed-case
vim.o.smartcase = true
-- Show a line down column 81 to indicate the 80 column limit
vim.o.colorcolumn = 81

if vim.g.neovide then
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

require('showmaps')
wk.register({["\\m"] = { "<cmd>ShowMaps<cr>", "Show Maps" }}, { })

vim.cmd [[
" Allow leaving terminal mode with <C-hjkl>
:tnoremap <C-h> <C-\><C-N><C-w>h
:tnoremap <C-j> <C-\><C-N><C-w>j
:tnoremap <C-k> <C-\><C-N><C-w>k
:tnoremap <C-l> <C-\><C-N><C-w>l
]]

-- Disable line numbers and start insert mode when opening a terminal
vim.api.nvim_create_autocmd('TermOpen', {
  once = true,
  callback = function(args)
    vim.o.number = false
    vim.o.relativenumber = false
    vim.cmd('startinsert')
  end,
})

-- indent blanklines
require("ibl").setup()
