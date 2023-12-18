return {
  {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
    },
    formatters = {
      stylua = { command = "stylua" },
    },
  },
  },
}
