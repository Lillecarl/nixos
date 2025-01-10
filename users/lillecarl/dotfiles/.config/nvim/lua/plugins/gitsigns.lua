M = {}

function M.setup(cfg)
  return {
    "gitsigns",
    event = "DeferredUIEnter",
    after = function()
      require("gitsigns").setup({})
    end,
  }
end

return M
