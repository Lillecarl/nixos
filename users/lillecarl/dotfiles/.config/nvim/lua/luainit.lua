M = {}

function M.setup(cfg)
  -- vim.opt.rtp:append(vim.fn.stdpath "config" .. "/lua/plugins")
  require("config").setup(cfg)
  require("plugins").setup(cfg)
end

return M
