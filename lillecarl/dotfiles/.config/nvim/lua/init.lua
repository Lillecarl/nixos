local M = {}

function M.setup(config)
  require("config").setup(config)
  require("plugins").setup(config)
end

return M
