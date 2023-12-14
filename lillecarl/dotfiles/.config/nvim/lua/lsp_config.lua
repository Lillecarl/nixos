local lsp = require('lspconfig')
local wk = require('which-key')
local cmp = require('cmp')
local copilot_sug = require("copilot.suggestion")

-- configure neodev early
require("neodev").setup({})
require('snippy').setup({})

cmp.setup({
  sources = {
    { name = 'nvim_lsp' }
  },
  mapping = cmp.mapping.preset.insert({
    ['<CS-k>']    = cmp.mapping.scroll_docs(-4),
    ['<CS-j>']    = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>']     = cmp.mapping.abort(),
    ['<M-k>']     = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })),
    ['<M-j>']     = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })),
    ['<tab>']     = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    -- accept currently selected item or first item or copilot suggestion
    ['<M-l>']     = cmp.mapping(
    function(_)
      if cmp.visible() and cmp.get_active_entry() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      elseif copilot_sug.is_visible() then
        copilot_sug.accept_line()
      end
    end),
  }),
  snippet = {
    expand = function(args)
      require('snippy').expand_snippet(args.body)
    end,
  },
})

local cmp_lsp_cap = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities(),
  -- File watching is disabled by default for neovim.
  -- See: https://github.com/neovim/neovim/pull/22405
  { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
);
cmp_lsp_cap.textDocument.completion.completionItem.snippetSupport = true

lsp.terraform_lsp.setup({
  capabilities = cmp_lsp_cap,
  cmd = { "terraform-lsp" },
  filetypes = { "terraform", "tf", "hcl" },
})
lsp.nil_ls.setup({
  capabilities = cmp_lsp_cap,
})
lsp.lua_ls.setup({
  capabilities = cmp_lsp_cap,
})
lsp.pyright.setup({
  capabilities = cmp_lsp_cap,
})
lsp.html.setup({
  capabilities = cmp_lsp_cap,
})

wk.register({
  ["<space>e"] =  { vim.diagnostic.open_float,  "Open diagnostics" },
  ["[d"] =        { vim.diagnostic.goto_prev,   "Previous diagnostic" },
  ["]d"] =        { vim.diagnostic.goto_next,   "Next diagnostic" },
  ["<space>q"] =  { vim.diagnostic.setloclist,  "Set loclist" },
},{ })

-- Disable copilot suggestions when cmp is active
cmp.event:on("menu_opened", function()
  vim.b.copilot_suggestion_hidden = true
end)

cmp.event:on("menu_closed", function()
  vim.b.copilot_suggestion_hidden = false
end)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    wk.register({
      ["gD"] =        { vim.lsp.buf.declaration,              "Goto declaration" },
      ["gd"] =        { vim.lsp.buf.definition,               "Goto definition" },
      ["K"] =         { vim.lsp.buf.hover,                    "Hover" },
      ["gi"] =        { vim.lsp.buf.implementation,           "Goto implementation" },
      ["<C-k>"] =     { vim.lsp.buf.signature_help,           "Signature help" },
      ["<space>wa"] = { vim.lsp.buf.add_workspace_folder,     "Add workspace folder" },
      ["<space>wr"] = { vim.lsp.buf.remove_workspace_folder,  "Remove workspace folder" },
      ["<space>wl"] = { function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, "List workspace folders" },
      ["<space>D"] =  { vim.lsp.buf.type_definition,          "Goto type definition" },
      ["<space>rn"] = { vim.lsp.buf.rename,                   "Rename" },
      ["<space>ca"] = { vim.lsp.buf.code_action,              "Code action" },
      ["gr"] =        { vim.lsp.buf.references,               "Goto references" },
      ["<space>f"] =  { function()
        vim.lsp.buf.format { async = true }
      end, "Format" },
    }, { buffer = ev.buf })
  end,
})
