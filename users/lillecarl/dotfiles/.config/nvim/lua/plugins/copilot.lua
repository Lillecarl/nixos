M = {}

function M.setup(cfg)
  return {
    "copilot",
    event = "DeferredUIEnter",
    after = function()
      require("copilot").setup({
        filetypes = {
          lua = true,
          nix = true,
          yaml = true,
          markdown = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
        },
        panel = {
          enabled = true,
          auto_refresh = true,
        },
      })
    end,
  }
end

return M
