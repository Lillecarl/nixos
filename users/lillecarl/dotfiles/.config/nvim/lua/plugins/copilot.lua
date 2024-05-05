local wk = require("which-key")

-- Setup copilot without any mappings
local copilot = require("copilot")
copilot.setup({
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = false,
      accept_word = false,
      accept_line = false,
      next = false,
      prev = false,
      dismiss = false,
    },
  },
  filetypes = {
    TelescopePrompt = false,
  },
})

-- Configure mappings when copilot is enabled for the current buffer
vim.api.nvim_create_autocmd("BufEnter", {
  group = "copilot.suggestion",
  callback = function()
    local util = require("copilot.util")
    local suggestion = require("copilot.suggestion")
    if util.should_attach() then
      wk.register({
        ["<M-l>"] = { suggestion.accept, "Copilot: Accept" },
        ["<M-]>"] = { suggestion.next, "Copilot: Next" },
        ["<M-[>"] = { suggestion.prev, "Copilot: Previous" },
        ["<C-]>"] = { suggestion.dismiss, "Copilot: Dismiss" },
      }, { mode = "i", buffer = vim.api.nvim_get_current_buf() })
    end
  end,
  desc = "[copilot] bindings",
})
