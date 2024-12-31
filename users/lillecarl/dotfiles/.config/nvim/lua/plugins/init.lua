M = {}

function M.config(cfg)
  require("lze").register_handlers(require("lze.x"))
  require("lze").load({
    {
      "multicursors.nvim",
      event = "DeferredUIEnter",
      dependencies = {
        "nvimtools/hydra.nvim",
      },
      cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
      keys = {
        {
          mode = { "v", "n" },
          "<Leader>m",
          "<cmd>MCstart<cr>",
          desc = "Create a selection for selected text or word under the cursor",
        },
      },
      after = function()
        require("multicursors").setup({})
      end,
    },
    {
      "catppuccin",
      event = "DeferredUIEnter",
      after = function()
        require("catppuccin").setup({})
        vim.cmd.colorscheme "catppuccin"
      end,
    },
    {
      "hydra.nvim",
      dep_of = "multicursors.nvim",
    },
    {
      "which-key",
      event = "DeferredUIEnter",
      keys = {
        {
          mode = { "v", "n" },
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
        after = function()
          local wk = require("which-key")
        end,
    },
    {
      "nvim-treesitter",
      event = "DeferredUIEnter",
        after = function()
          require("nvim-treesitter.configs").setup({

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
})
        end,
    },
  })

end

return M
