local M = {}

function M.setup(_)
  if not vim.g.vscode then
    require("plugins.multiplug")
  end
  require("plugins.tree-sitter")
  require("plugins.lspconfig")
  require("plugins.cmp")
end

return M
