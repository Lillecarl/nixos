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
  ["<leader>"] = {
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

wk.register({["<M-c>"] = { '<cmd>bdelete<cr>', "Close buffer" }}, { mode = "n" })

-- No mouse thanks
vim.o.mouse = false
-- Show line numbers relative to cursor
vim.o.number = true
vim.o.relativenumber = true
-- utf-8 as default encoding
vim.o.encoding="utf-8"
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

require('showmaps')
wk.register({["\\m"] = { "<cmd>ShowMaps<cr>", "Show Maps" }}, { })

-- indent blanklines
require("ibl").setup()
