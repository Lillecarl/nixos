M = {}

function M.setup(cfg)
  require("lze").load({
    require("plugins.tree-sitter").setup(cfg),
    require("plugins.catppuccin").setup(cfg),
    require("plugins.conform").setup(cfg),
    require("plugins.mini").setup(cfg),
    require("plugins.multicursors").setup(cfg),
    require("plugins.which-key").setup(cfg),
    require("plugins.ibl").setup(cfg),
    require("plugins.lspconfig").setup(cfg),
    require("plugins.completion").setup(cfg),
    require("plugins.copilot").setup(cfg),
    require("plugins.copilotchat").setup(cfg),
    require("plugins.gitsigns").setup(cfg),
  })
end

return M
