local M = {}

function M.setup(_) -- paths
  require("config")
  if not vim.g.vscode then
    require("plugins")
  end
end

return M
