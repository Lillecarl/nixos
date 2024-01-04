-- which-key
local wk = require("which-key")
wk.register({ w = { "<cmd>WhichKey<cr>", "Toggle WhichKey" } }, { prefix = "<leader>" })

-- catppuccin theme
require("catppuccin").setup({})
vim.cmd.colorscheme("catppuccin")

-- copilot
require("copilot").setup({
  suggestion = {
    auto_trigger = true,
  },
})

-- telescope
require("telescope").setup({})

local ts_builtin = require("telescope.builtin")

wk.register({
  f = {
    name = "Find",
    f = { ts_builtin.find_files, "Find Files" },
    g = { ts_builtin.live_grep, "Live Grep" },
    b = { ts_builtin.buffers, "Buffers" },
    h = { ts_builtin.help_tags, "Help Tags" },
  },
}, { prefix = "<leader>" })

-- neodev
-- https://github.com/folke/neodev.nvim
require("neodev").setup({})

-- nvim-tree, tree plugin

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- https://github.com/nvim-tree/nvim-tree.lua
require("nvim-tree").setup()
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
