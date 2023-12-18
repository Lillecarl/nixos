return {
  -- Disable mason.nvim, we already have the best package manager Nix.
  {
    "williamboman/mason.nvim",
    enabled = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {},
        lua_ls = {},
        nil_ls = {},
      },
    },
  },
}
