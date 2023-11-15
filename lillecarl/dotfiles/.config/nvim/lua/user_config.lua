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
