local M = {}

function M.setup(config)
  local conform = require("conform")
  local formatters_by_ft = conform.formatters_by_ft
  local nixFormatters = config["fmt"]

  conform.setup({
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_fallback = true,
    },
    log_level = vim.log.levels.DEBUG,
    notify_on_error = true,
  })

  require("conform").formatters.terragrunt_fmt = {
    command = "", -- Populated by Nix
    args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
    stdin = false,
  }

  for key, value in pairs(nixFormatters) do
    local status, result = pcall(require, "conform.formatters." .. key)
    if not status then
      result = require("conform").formatters[key]
    end
    require("conform").formatters[key] = vim.tbl_deep_extend("force", result or {}, value)
  end

  --formatters_by_ft.yaml = { "yamlfmt" }
  formatters_by_ft.bash = { "shellcheck" }
  formatters_by_ft.fish = { "fish_indent" }
  formatters_by_ft.go = { "gofmt", "goimports", "golines" }
  formatters_by_ft.hcl = { "terragrunt_fmt" }
  formatters_by_ft.javascript = { "prettierd" }
  formatters_by_ft.json = { "fixjson" }
  formatters_by_ft.lua = { "stylua" }
  formatters_by_ft.nix = { "nixpkgs_fmt" }
  formatters_by_ft.packer = { "packer_fmt" }
  formatters_by_ft.python = { "isort", "black" }
  formatters_by_ft.rust = { "rustfmt" }
  formatters_by_ft.terraform = { "terraform_fmt" }
  formatters_by_ft.terragrunt = { "terragrunt_fmt" }
  formatters_by_ft.toml = { "taplo" }
  formatters_by_ft.yaml = { "yamlfix" }

  -- Not yet sure why this is required
  --require("conform").formatters = formatters
  require("conform").formatters_by_ft = formatters_by_ft
end

return M
