-- which-key
require("which-key").setup({
  triggers_nowait = {
    "<leader>",
    "<Space>",
    "<M-Space>",
  },
})
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

require("neoconf").setup({})
-- neodev
-- https://github.com/folke/neodev.nvim
require("neodev").setup({
  pathStrict = false,
  library = {
    enabled = true,
    runtime = true,
    types = true,
    plugins = true,
  },
})

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

local bindToBuffer = function(ev)
  local leader = {
    m = {
      name = "Messages",
      m = { "<cmd>Noice<cr>", "Show messages" },
      d = { "<cmd>NoiceDismiss<cr>", "Dismiss messages" },
    },
  }

  wk.register(leader, { prefix = "<leader>", buffer = ev.buf })
  wk.register(leader, { prefix = "<M-space>", buffer = ev.buf, mode = "i" })
end

vim.api.nvim_create_autocmd({ "User" }, {
  group = "RealBufferBind",
  callback = bindToBuffer,
})

-- trouble
-- https://github.com/folke/trouble.nvim
require("trouble").setup({})

--wk.register({
--  v = { name = "Visual mode" },
--  y = { name = "Yank" },
--})

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
