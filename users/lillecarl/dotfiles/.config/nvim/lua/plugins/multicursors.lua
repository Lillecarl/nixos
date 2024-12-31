M = {}

function M.setup(cfg)
  return {
    "multicursors.nvim",
    event = "DeferredUIEnter",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
    after = function()
      require("multicursors").setup({})
    end,
  }
end

return M
