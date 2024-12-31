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
  })
end

return M
