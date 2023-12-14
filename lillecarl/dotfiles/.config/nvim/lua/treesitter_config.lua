require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,

    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
  },
  indent = {
    enable = true
  },
})

--vim.cmd [[
--  set foldmethod=expr
--  set foldexpr=nvim_treesitter#foldexpr()
--  set foldlevel=20
--]]
