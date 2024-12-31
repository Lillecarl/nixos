M = {}

function M.config(config) 
  -- vim.opt.rtp:append(vim.fn.stdpath "config" .. "/lua/plugins")
  require("plugins").config(config)
end

return M
