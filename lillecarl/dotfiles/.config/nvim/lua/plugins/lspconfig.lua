local M = {}

function M.setup(config)
  -- which-key
  local wk = require("which-key")

  -- Setup language servers.
  local lspconfig = require("lspconfig")

  local paths = config["lsp"]["paths"]

  lspconfig.ansiblels.setup({ cmd = { paths["ansiblels"], "--stdio" } })
  lspconfig.bashls.setup({ cmd = { paths["bashls"], "start" } })
  lspconfig.clangd.setup({ cmd = { paths["clangd"] } })
  lspconfig.cmake.setup({ cmd = { paths["cmake"] } })
  lspconfig.cssls.setup({ cmd = { paths["cssls"], "--stdio" } })
  lspconfig.dockerls.setup({ cmd = { paths["dockerls"], "--stdio" } })
  lspconfig.dotls.setup({ cmd = { paths["dotls"], "--stdio" } })
  lspconfig.eslint.setup({ cmd = { paths["eslint"], "--stdio" } })
  lspconfig.gopls.setup({ cmd = { paths["eslint"], "--stdio" } })
  lspconfig.html.setup({ cmd = { paths["html"], "--stdio" } })
  lspconfig.jsonls.setup({ cmd = { paths["jsonls"], "--stdio" } })
  lspconfig.lua_ls.setup({ cmd = { paths["lua_ls"] } })
  lspconfig.marksman.setup({ cmd = { paths["marksman"] } })
  lspconfig.nil_ls.setup({ cmd = { paths["nil_ls"] } })
  --lspconfig.nixd.setup({ cmd = { paths["nixd"] } })
  lspconfig.nushell.setup({ cmd = { paths["nushell"], "--lsp" } })
  lspconfig.omnisharp.setup({ cmd = { paths["omnisharp"] } })
  lspconfig.perlls.setup({ cmd = { paths["perlls"] } })
  lspconfig.postgres_lsp.setup({ cmd = { paths["postgres_lsp"] } })
  lspconfig.psalm.setup({ cmd = { paths["psalm"], "--language-server" } })
  lspconfig.pyright.setup({ cmd = { paths["pyright"], "--stdio" } })
  lspconfig.ruby_ls.setup({ cmd = { paths["ruby_ls"] } })
  lspconfig.rust_analyzer.setup({ cmd = { paths["rust_analyzer"] } })
  lspconfig.terraformls.setup({ cmd = { paths["terraformls"] } })
  lspconfig.tsserver.setup({ cmd = { paths["tsserver"], "--stdio" } })
  lspconfig.vimls.setup({ cmd = { paths["vimls"], "--stdio" } })
  lspconfig.yamlls.setup({ cmd = { paths["yamlls"], "--stdio" } })
  lspconfig.zls.setup({ cmd = { paths["zls"] } })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      wk.register({
        ["gD"] = { vim.lsp.buf.declaration, "Go to declaration" },
        ["gd"] = { vim.lsp.buf.definition, "Go to definition" },
        ["K"] = { vim.lsp.buf.hover, "Hover" },
        ["gi"] = { vim.lsp.buf.implementation, "Go to implementation" },
        ["gr"] = { vim.lsp.buf.references, "Go to references" },
        ["<C-k>"] = { vim.lsp.buf.signature_help, "Signature help" },
      }, {
        buffer = ev.buf,
      })
      wk.register({
        l = {
          name = "LSP",
          w = {
            name = "Workspace",
            ["a"] = { vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
            ["r"] = { vim.lsp.buf.remove_workspace_folder, "Remove workspace folder" },
            ["l"] = {
              function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end,
              "List workspace folders",
            },
          },
          ["D"] = { vim.lsp.buf.type_definition, "Go to type definition" },
          ["r"] = { vim.lsp.buf.rename, "Rename" },
          ["a"] = { vim.lsp.buf.code_action, "Code action" },
          ["f"] = {
            function()
              require("conform").format()
            end,
            "Format",
          },
        },
      }, {
        buffer = ev.buf,
        prefix = "<leader>",
      })

      wk.register({
        ["<leader>lca"] = { vim.lsp.buf.code_action, "Code action" },
      }, {
        buffer = ev.buf,
        mode = "v",
      })
    end,
  })
end

return M
