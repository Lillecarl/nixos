local M = {}

function M.setup(config)
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
  -- case insesitive search when searching with only lowercase letters
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  -- show line numbers
  vim.opt.number = true

  local font = config["ui"]["font"]
  if vim.g.neovide then
    vim.opt.guifont = font["name"] .. ":h" .. font["size"]
    vim.g.neovide_fullscreen = false
    vim.g.neovide_remember_window_size = false
  end

  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
        vim.api.nvim_win_set_cursor(0, mark)
      end
    end,
  })

  if not vim.g.vscode then
    local wk = require("which-key")
    wk.register({
      u = { "<cmd>wincmd h<cr>", "Go to the left window" },
    }, { prefix = "<ESC>" })
    -- <M-t> is alt+t
    -- <C-t> is ctrl+t
    -- <T-t> is meta+t
    wk.register({
      ["<M-t>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle nvim-tree" },
      ["<C-t>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle nvim-tree" },
      ["<T-t>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle nvim-tree" },
      ["<M-g>"] = {
        function()
          print("message")
          vim.notify("OFF", vim.log.levels.OFF, { title = "OFF" })
          vim.notify("ERROR", vim.log.levels.ERROR, { title = "ERROR" })
          vim.notify("WARN", vim.log.levels.WARN, { title = "WARN" })
          vim.notify("INFO", vim.log.levels.INFO, { title = "INFO" })
          vim.notify("DEBUG", vim.log.levels.DEBUG, { title = "DEBUG" })
          vim.notify("TRACE", vim.log.levels.TRACE, { title = "TRACE" })
        end,
        "Run test function",
      },
      ["<M-h>"] = { "<cmd>wincmd h<cr>", "Go to the left window" },
      ["<M-j>"] = { "<cmd>wincmd j<cr>", "Go to the down window" },
      ["<M-k>"] = { "<cmd>wincmd k<cr>", "Go to the up window" },
      ["<M-l>"] = { "<cmd>wincmd l<cr>", "Go to the right window" },
      ["<M-c>"] = { "<cmd>bdelete<cr>", "Close buffer" },
      ["<M-x>"] = { "<cmd>xall<cr>", "Save all and exit" },
    })
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
  end

  vim.api.nvim_create_autocmd({ "FileType", "VimEnter", "BufAdd" }, {
    callback = realBufferBind,
  })
end

return M
