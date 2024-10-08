local M = {}

function M.setup(config)
  -- which-key
  local wk = require("which-key")

  -- Setup language servers.
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities({
    dynamicRegistration = true,
  })

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
          ["x"] = { vim.lsp.buf.definition, "Go to type definition" },
          ["d"] = { vim.lsp.buf.type_definition, "Go to type definition" },
          ["r"] = { vim.lsp.buf.rename, "Rename" },
          ["a"] = { vim.lsp.buf.code_action, "Action" },
          ["h"] = { vim.lsp.buf.hover, "Hover" },
          ["i"] = { vim.lsp.buf.implementation, "Implementation" },
          ["m"] = { vim.lsp.buf.references, "Find references" },
          ["f"] = {
            function()
              vim.notify("Formatting with conform", vim.log.levels.INFO, { title = "Formatting" })
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
