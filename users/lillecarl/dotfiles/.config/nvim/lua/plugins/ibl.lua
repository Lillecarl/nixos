M = {}

function M.setup(cfg)
  return {
    "ibl",
    event = "DeferredUIEnter",
    after = function()
      require("ibl").setup()
    end
  }
end

return M
