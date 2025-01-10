M = {}

function M.setup(_)
  return {
    "lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    before = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.terraformls.setup({
        capabilities = capabilities,
      })
      lspconfig.nil_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.basedpyright.setup({
        capabilities = capabilities,
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              -- library = {
              --   vim.env.VIMRUNTIME,
              --   -- vim.o.packpath,
              --   "/nix/store/9srha81b51shi545vx3ciz206bayhbad-vim-pack-dir/pack/myNeovimPackages/start",
              -- },
            },
          },
        },
      })
    end,
  }
end

return M
