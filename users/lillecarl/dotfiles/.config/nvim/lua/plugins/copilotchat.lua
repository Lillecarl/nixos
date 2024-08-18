local M = {}

function M.setup(config)
  require("CopilotChat").setup({
    show_help = "yes", -- Show help text for CopilotChatInPlace, default: yes
    debug = false, -- Enable or disable debug mode, the log file will be in ~/.local/state/nvim/CopilotChat.nvim.log
    disable_extra_info = "no", -- Disable extra information (e.g: system prompt) in the response.
  })

  --" python3 plugins
  --call remote#host#RegisterPlugin('python3', '/Users/huynhdung/.local/share/nvim/lazy/CopilotChat.nvim/rplugin/python3/copilot-plugin.py', [
  --      \ {'sync': v:false, 'name': 'CopilotChat', 'type': 'command', 'opts': {'nargs': '1'}},
  --      \ {'sync': v:false, 'name': 'CopilotChatVisual', 'type': 'command', 'opts': {'nargs': '1', 'range': ''}},
  --      \ {'sync': v:false, 'name': 'CopilotChatInPlace', 'type': 'command', 'opts': {'nargs': '*', 'range': ''}},
  --      \ {'sync': v:false, 'name': 'CopilotChatAutocmd', 'type': 'command', 'opts': {'nargs': '*'}},
  --      \ {'sync': v:false, 'name': 'CopilotChatMapping', 'type': 'command', 'opts': {'nargs': '*'}},
  --     \ ])
end

return M
