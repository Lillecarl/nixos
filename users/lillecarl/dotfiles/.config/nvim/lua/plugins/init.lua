local M = {}

function M.setup(config)
  require("plugins.multiplug")
  require("plugins.conform").setup(config)
  require("plugins.telescope").setup(config)
  require("plugins.copilot")
  require("plugins.tree-sitter")
  require("plugins.cmp")
  require("plugins.lspconfig").setup(config)
  require("plugins.copilotchat").setup(config)
  require("plugins.aerial")
end

return M
