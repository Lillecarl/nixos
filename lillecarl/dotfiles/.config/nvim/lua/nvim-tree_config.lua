local nvim_tree = require('nvim-tree')
local nvim_tree_api = require('nvim-tree.api')
local wk = require('which-key')

-- disable netrw at the very start of your init.lua
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

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

  wk.register({
    ["<C-t>"] = { nvim_tree_api.tree.toggle, "Toggle nvim-tree" },
    ["?"] = { nvim_tree_api.tree.toggle_help, "Toggle nvim-tree help" },
  }, opts(bufnr))
end

nvim_tree.setup({
  on_attach = nvim_tree_attach,
  hijack_unnamed_buffer_when_opening = false,
  disable_netrw = true,
})

-- register ctrl+t to toggle nvim-tree
wk.register({
  ["<C-t>"] = { nvim_tree_api.tree.toggle, "Toggle nvim-tree" },
})
