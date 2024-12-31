M = {}

function M.setup(cfg)
  return {
    "catppuccin",
    event = "DeferredUIEnter",
    after = function()
      require("catppuccin").setup()
      vim.cmd.colorscheme "catppuccin"
    end
  }
end

return M
