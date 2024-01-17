local M = {}

function M.setup(_)
  -- Space is leader
  vim.g.mapleader = " "
  -- Something from LazyVim
  vim.g.maplocalleader = "\\"
  -- Copy to system clipboard by default
  vim.opt.clipboard = "unnamedplus"
  -- disable netrw
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  -- no idea, from nvim-tree config example
  vim.opt.termguicolors = true
  -- case insesitive search when searching with only lowercase letters
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
end

return M
