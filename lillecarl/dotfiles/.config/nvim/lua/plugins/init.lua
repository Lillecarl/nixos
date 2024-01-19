local M = {}

function M.setup(config)
  if not vim.g.vscode then
    require("plugins.multiplug")
    require("plugins.conform").setup(config)
    require("plugins.telescope").setup(config)
    require("plugins.copilot")
    require("plugins.tree-sitter")
    require("plugins.lspconfig").setup(config)
    require("plugins.cmp")
  end
end

return M
