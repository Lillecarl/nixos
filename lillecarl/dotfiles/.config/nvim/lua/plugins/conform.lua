local M = {}

function M.setup(config)
  local conform = require("conform")
  local formatters = conform.formatters
  local formatters_by_ft = conform.formatters_by_ft
  local paths = config["fmt"]["paths"]

  conform.setup({
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_fallback = true,
    },
    log_level = vim.log.levels.DEBUG,
    notify_on_error = true,
  })

  formatters_by_ft.python = { "isort", "black" }
  formatters.black = { command = paths["black"] }
  formatters.isort = { command = paths["isort"] }

  formatters_by_ft.lua = { "stylua" }
  formatters.stylua = { command = paths["stylua"] }

  formatters_by_ft.javascript = { "prettier" }
  formatters.prettier = { command = paths["prettier"] }

  formatters_by_ft.nix = { "nixpkgs_fmt" }
  formatters.nixpkgs_fmt = { command = paths["nixpkgs_fmt"] }

  formatters_by_ft.terraform = { "terraform_fmt" }
  formatters.terraform_fmt = { command = paths["terraform_fmt"] }

  formatters_by_ft.hcl = { "terragrunt_fmt" }
  formatters_by_ft.terragrunt = { "terragrunt_fmt" }
  formatters.terragrunt_fmt = {
    command = paths["terragrunt_fmt"],
    args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
    stdin = false,
  }

  formatters_by_ft.json = { "fixjson" }
  formatters.fixjson = { command = paths["fixjson"] }

  formatters_by_ft.rust = { "rustfmt" }
  formatters.rustfmt = { command = paths["rustfmt"] }

  formatters_by_ft.bash = { "shellcheck" }
  formatters.shellcheck = { command = paths["shellcheck"] }

  formatters_by_ft.yaml = { "yamlfmt" }
  formatters.yamlfmt = { command = paths["yamlfmt"] }

  formatters_by_ft.packer = { "packer_fmt" }
  formatters.packer_fmt = { command = paths["packer_fmt"] }

  formatters.clang_format = { command = paths["clang_format"] }

  -- Not yet sure why this is required
  require("conform").formatters = formatters
  require("conform").formatters_by_ft = formatters_by_ft
end

return M
