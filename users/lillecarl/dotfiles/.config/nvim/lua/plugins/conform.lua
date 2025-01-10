M = {}

function M.setup(cfg)
  return {
    "conform",
    event = "DeferredUIEnter",
    keys = {
      {
        mode = { "v", "n" },
        "<leader>f",
        function()
          require("conform").format()
        end,
        desc = "Format w/ Conform",
      },
    },
    after = function()
      require("conform").setup({
        format_after_save = {
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          rust = { "rustfmt", lsp_format = "fallback" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          fish = { "fish_indent" },
        },
      })
    end,
  }
end

return M
