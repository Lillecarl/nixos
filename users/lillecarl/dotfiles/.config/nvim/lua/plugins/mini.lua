M = {}

function M.setup(cfg)
  return {
    "mini.nvim",
    event = "DeferredUIEnter",
    after = function()
      require("mini.comment").setup({
        mappings = {
          comment_visual = "<leader>c",
          comment_line = "<leader>c",
        },
      })
    end,
  }
end

return M
