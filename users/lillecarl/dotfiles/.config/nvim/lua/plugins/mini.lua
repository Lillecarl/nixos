M = {}

function M.setup(cfg)
  return {
    "mini.nvim",
    event = "DeferredUIEnter",
    after = function()
      require("mini.comment").setup({
        mappings = {
          comment_visual = "c",
        },
      })
      require("which-key").add({
        {
          mode = { "n" },
          "<leader>c",
          function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            MiniComment.toggle_lines(row, row, {})
          end,
          desc = "Comment cur line",
        },
      })
    end,
  }
end

return M
