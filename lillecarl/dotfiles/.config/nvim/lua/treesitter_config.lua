require('nvim-treesitter.configs').setup({
  indent = { enable = true },
})

vim.cmd [[
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
  set foldlevel=20
]]
