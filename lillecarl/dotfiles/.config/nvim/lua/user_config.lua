-- Setup nvim-tree
local nvim_tree_api = require "nvim-tree.api"

local function nvim_tree_attach(bufnr)
  local nvim_tree_api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  nvim_tree_api.config.mappings.default_on_attach(bufnr)

  -- custom mappings (Within nvim-tree buffer)
  vim.keymap.set('n', '<C-t>', nvim_tree_api.tree.toggle, {})
  vim.keymap.set('n', '?',     nvim_tree_api.tree.toggle_help,                  opts('Help'))
end
require("nvim-tree").setup({
  on_attach = nvim_tree_attach,
})

-- Setup nvim-tree bindings
vim.keymap.set('n', '<C-t>', nvim_tree_api.tree.toggle, {})


-- Configure NERDTree bindings
--[[
--vim.cmd [[
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
]]
--]]
--
vim.cmd [[
:tnoremap <C-h> <C-\><C-N><C-w>h
:tnoremap <C-j> <C-\><C-N><C-w>j
:tnoremap <C-k> <C-\><C-N><C-w>k
:tnoremap <C-l> <C-\><C-N><C-w>l

vim.api.nvim_create_autocmd('TermOpen', {
  once = true,
  callback = function(args)
    --local resp = args.data
    --local r, g, b = resp:match("\x1b%]4;1;rgb:(%w+)/(%w+)/(%w+)")
    vim.cmd('startinsert')
  end,
})
