local M = {}

function M.setup(cfg)
  -- Space is leader
  vim.g.mapleader = " "
  -- Something from LazyVim
  vim.g.maplocalleader = "\\"
  -- Copy to system clipboard by default
  vim.opt.clipboard = "unnamedplus"
  -- disable netrw
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  -- no idea, from nvim-tree config example
  vim.opt.termguicolors = true
  -- case insensitive search when searching with only lowercase letters
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  -- show line numbers
  vim.opt.number = true

  local function fulldate()
    return os.date("%y-%m-%d %H:%M:%S")
  end
  local function clock()
    return os.date("%H:%M:%S")
  end

  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
        vim.api.nvim_win_set_cursor(0, mark)
      end
    end,
  })

  local function smart_dd()
    if vim.api.nvim_get_current_line():match("^%s*$") then
      return '"_dd'
    else
      return "dd"
    end
  end

  local wk = require("which-key")
  -- <M-t> is alt+t
  -- <C-t> is ctrl+t
  -- <T-t> is meta+t
  -- wk.register(
  -- {
  --   { "<C-c>", "<cmd>qall!<cr>", desc = "Close all and exit" },
  --   { "<C-t>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle nvim-tree" },
  --   { "<M-c>", "<cmd>bdelete<cr>", desc = "Close buffer" },
  --   { "<M-g>",
  --     function()
  --       print("message")
  --       vim.notify("OFF", vim.log.levels.OFF, { title = "OFF" })
  --       vim.notify("ERROR", vim.log.levels.ERROR, { title = "ERROR" })
  --       vim.notify("WARN", vim.log.levels.WARN, { title = "WARN" })
  --       vim.notify("INFO", vim.log.levels.INFO, { title = "INFO" })
  --       vim.notify("DEBUG", vim.log.levels.DEBUG, { title = "DEBUG" })
  --       vim.notify("TRACE", vim.log.levels.TRACE, { title = "TRACE" })
  --     end
  --   , desc = "Run test function" },
  --   { "<M-h>", "<cmd>wincmd h<cr>", desc = "Go to the left window" },
  --   { "<M-j>", "<cmd>wincmd j<cr>", desc = "Go to the down window" },
  --   { "<M-k>", "<cmd>wincmd k<cr>", desc = "Go to the up window" },
  --   { "<M-l>", "<cmd>wincmd l<cr>", desc = "Go to the right window" },
  --   { "<M-t>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle nvim-tree" },
  --   { "<M-x>", "<cmd>xall<cr>", desc = "Save all and exit" },
  --   { "<T-t>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle nvim-tree" },
  -- })
end

vim.api.nvim_create_user_command("Die", "xall", {})

local augrp = vim.api.nvim_create_augroup("RealBufferBind", {})
local realBufferBind = function(ev)
  if ev.event == "FileType" then
    local blocked_filetypes = {
      "TelescopePrompt",
      "TelescopeResults",
      "WhichKey",
      "notify",
      "noice",
      "nofile",
    }

    for _, i in ipairs(blocked_filetypes) do
      if vim.bo.filetype == i then
        return
      end
    end
  end

  -- Create a user autocmd group that runs when we enter a real buffer
  -- Useful for configuring binds without disturbing extensions
  vim.api.nvim_exec_autocmds("User", { group = augrp })

  vim.api.nvim_create_autocmd({ "FileType", "VimEnter", "BufAdd" }, {
    callback = realBufferBind,
  })
end

return M
