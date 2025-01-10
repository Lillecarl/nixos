M = {}

function M.setup(cfg)
  return {
    "copilot",
    event = "DeferredUIEnter",
    after = function()
      require("copilot").setup({})
    end,
  }
end

return M
