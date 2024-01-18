-- which-key
local wk = require("which-key")
wk.register({
  i = { "<cmd>WhichKey '' i<cr>", "Show WhichKey insert bindings" },
  n = { "<cmd>WhichKey '' n<cr>", "Show WhichKey insert bindings" },
}, { prefix = "<leader>w" })

-- catppuccin theme
require("catppuccin").setup({
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
  },
})
vim.cmd.colorscheme("catppuccin")

-- neodev
-- https://github.com/folke/neodev.nvim
require("neodev").setup({})

-- nvim-tree, tree plugin
-- https://github.com/nvim-tree/nvim-tree.lua
local treeapi = require("nvim-tree.api")
require("nvim-tree").setup({
  disable_netrw = true,
  filters = {
    dotfiles = false,
    custom = {},
  },
  on_attach = function(bufnr)
    treeapi.config.mappings.default_on_attach(bufnr)
  end,
})
wk.register({ t = { "<cmd>NvimTreeToggle<cr>", "Toggle NvimTree" } }, { prefix = "<leader>" })

-- indent blanklines
-- https://github.com/lukas-reineke/indent-blankline.nvim
require("ibl").setup()

-- nvim-notify
-- https://github.com/rcarriga/nvim-notify
vim.notify = require("notify")

-- noice, cmdline and others
-- https://github.com/folke/noice.nvim
require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

-- trouble
-- https://github.com/folke/trouble.nvim
require("trouble").setup({})

-- conform, formatting
-- https://github.com/stevearc/conform.nvim
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { "prettier" },
    nix = { "nixpkgs_fmt" },
    terraform = { "terraform_fmt" },
    hcl = { "hclfmt" },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters = {
    hclfmt = {
      command = "terragrunt",
      args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
      stdin = false,
    },
  },
})

wk.register({
  v = { name = "Visual mode" },
  y = { name = "Yank" },
})

-- autopairs
-- https://github.com/windwp/nvim-autopairs
require("nvim-autopairs").setup({})

-- gitsigns
-- https://github.com/lewis6991/gitsigns.nvim
require("gitsigns").setup({
  current_line_blame = true,
})

-- overseer
-- https://github.com/stevearc/overseer.nvim
require("overseer").setup({})
