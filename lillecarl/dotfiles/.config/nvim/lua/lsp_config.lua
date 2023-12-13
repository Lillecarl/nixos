local lsp = require('lspconfig')
local wk = require('which-key')
local cmp = require('cmp')
local copilot_sug = require("copilot.suggestion")

-- configure neodev early
require("neodev").setup({})

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
    ['<M-l>']     = cmp.mapping(
    function(_)
      if cmp.visible() and cmp.get_active_entry() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      elseif copilot_sug.is_visible() then
        copilot_sug.accept_line()
      end
    end),
  }),
})

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local cmp_lsp_cap = require('cmp_nvim_lsp').default_capabilities()

lsp.terraform_lsp.setup({
  capabilities = cmp_lsp_cap,
  cmd = { "terraform-lsp" },
  filetypes = { "terraform", "tf", "hcl" },
})
lsp.nil_ls.setup({
  capabilities = cmp_lsp_cap,
})
lsp.lua_ls.setup({})

wk.register({
  ["<space>e"] =  { vim.diagnostic.open_float,  "Open diagnostics" },
  ["[d"] =        { vim.diagnostic.goto_prev,   "Previous diagnostic" },
  ["]d"] =        { vim.diagnostic.goto_next,   "Next diagnostic" },
  ["<space>q"] =  { vim.diagnostic.setloclist,  "Set loclist" },
},{ })

--[[
wk.register({
  ["<M-j>"] = {
    function()
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      end
    end,  "Sel next cmp" },
  ["<M-k>"] = {
    function()
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      end
    end,  "Sel prev cmp" },
  ["<M-l>"] = {
    function()
      if cmp.visible() then
        cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        })
      elseif copilot_sug.is_visible() then
        copilot_sug.accept_line()
      end
    end,  "Cmp complete" },
  ["<M-x>"] = {
    function()
      if cmp.visible() then
        cmp.mapping.abort()
      end
    end,  "Cmp abort" },
},{ mode = "i", })
--]]

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
