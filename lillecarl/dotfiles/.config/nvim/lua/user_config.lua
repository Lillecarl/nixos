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

vim.api.nvim_create_autocmd('TermOpen', {
  once = true,
  callback = function(args)
    --local resp = args.data
    --local r, g, b = resp:match("\x1b%]4;1;rgb:(%w+)/(%w+)/(%w+)")
    vim.cmd('startinsert')
  end,
})
