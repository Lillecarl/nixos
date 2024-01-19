local M = {}

function M.setup(config)
  local conform = require("conform")
  local formatters = conform.formatters
  local paths = config["fmt"]["paths"]

  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettier" },
      nix = { "nixpkgs_fmt" },
      terraform = { "terraform_fmt" },
      hcl = { "hclfmt" },
    },
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_fallback = true,
    },
  })

  formatters.black = { command = paths["black"] }
  formatters.clang_format = { command = paths["clang_format"] }
  formatters.isort = { command = paths["isort"] }
  formatters.nixpkgs_fmt = { command = paths["nixpkgs_fmt"] }
  formatters.packer_fmt = { command = paths["nixpkgs_fmt"] }
  formatters.fixjson = { command = paths["fixjson"] }
  formatters.prettier = { command = paths["prettier"] }
  formatters.rustfmt = { command = paths["rustfmt"] }
  formatters.shellcheck = { command = paths["shellcheck"] }
  formatters.stylua = { command = paths["stylua"] }
  formatters.terraform_fmt = { command = paths["terraform_fmt"] }
  formatters.terragrunt_fmt = {
    command = paths["terragrunt_fmt"],
    args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
    stdin = false,
  }
  formatters.yamlfmt = { command = paths["yamlfmt"] }
end

return M
