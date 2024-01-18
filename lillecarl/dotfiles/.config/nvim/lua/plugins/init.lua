local M = {}

function M.setup(_)
  if not vim.g.vscode then
    require("plugins.multiplug")
    require("plugins.copilot")
    require("plugins.tree-sitter")
    require("plugins.lspconfig")
    require("plugins.cmp")
  end
end

return M
