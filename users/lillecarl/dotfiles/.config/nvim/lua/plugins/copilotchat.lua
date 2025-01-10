M = {}

function M.setup(cfg)
  return {
    "CopilotChat",
    event = "DeferredUIEnter",
    after = function()
      require("CopilotChat").setup({})
    end,
  }
end

return M
