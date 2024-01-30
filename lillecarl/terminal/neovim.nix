{ pkgs
, self
, lib
, bp
, config
, ...
}:
let
  inherit (config.stylix) fonts;
in
{
  home.packages = [
    pkgs.tree-sitter # for TS troubleshooting
    pkgs.nvimpager # Use Neovim as pager
  ];

  stylix.targets.vim.enable = false;

  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    extraPackages = [
      # misc tools
      pkgs.fd # for telescope
      pkgs.ripgrep # for telescope
      pkgs.tree-sitter # silence tree-sitter warning
      pkgs.fzf # fuzzy finder
      pkgs.git # Gitsigns, Fugitive
      pkgs.go # Required for gopls
    ];

    plugins = with pkgs.vimPlugins; [
      #camelcasemotion
      #neogit
      #nvim-snippy
      #surround
      #tabby-nvim
      #tabmerge
      #toggleterm-nvim
      #vim-airline
      SchemaStore-nvim
      catppuccin-nvim
      cmp-git
      cmp-nvim-lsp
      conform-nvim
      copilot-lua
      fugitive
      gitsigns-nvim
      indent-blankline-nvim
      iron-nvim
      luasnip
      neoconf-nvim
      neodev-nvim
      noice-nvim
      nui-nvim
      nvim-autopairs
      nvim-cmp
      nvim-dap
      nvim-dap-ui
      nvim-dap-python
      nvim-lspconfig
      nvim-notify
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      overseer-nvim
      telescope-nvim
      trouble-nvim
      which-key-nvim
    ] ++ [
      pkgs.one-small-step-for-vimkind
    ];

    extraLuaConfig =
      let
        nodeLatest = pkgs.nodePackages_latest;
        config = {
          lsp =
            let
              bashls = "${nodeLatest.bash-language-server}/bin";
              dockerls = "${nodeLatest.dockerfile-language-server-nodejs}/bin";
              pyright = "${nodeLatest.pyright}/bin";
              tsserver = "${nodeLatest.typescript-language-server}/bin";
              vimls = "${nodeLatest.vim-language-server}/bin";
              vscode-ls = "${nodeLatest.vscode-langservers-extracted}/bin";
              yamlls = "${nodeLatest.yaml-language-server}/bin";

            in
            {
              # TODO: PowerShell
              ansiblels =
                let
                  ansibleLS = pkgs.callPackage "${self}/pkgs/tmp/ansible-language-server.nix" { };
                  ansibleLspFarm = pkgs.symlinkJoin {
                    name = "ansiPy";
                    paths = [
                      (pkgs.python3.withPackages (ps: [
                        ps.ansible
                      ]))
                      pkgs.ansible
                      pkgs.ansible-lint
                      #pkgs.ansible-language-server
                      ansibleLS
                    ];
                  };
                in
                {
                  cmd = [ "${ansibleLspFarm}/bin/ansible-language-server" "--stdio" ];
                  settings = {
                    ansible.ansible.path = "${ansibleLspFarm}/bin/ansible";
                    ansible.python.interpreterPath = "${ansibleLspFarm}/bin/python3";
                    ansible.validation.lint.path = "${ansibleLspFarm}/bin/ansible-lint";
                    #ansible.ansible.path = "ansible";
                    #ansible.python.interpreterPath = "python3";
                    #ansible.validation.lint.path = "ansible-lint";
                  };
                  nodefault = true;
                };
              #nixd = { cmd = [ (bp pkgs.nixd) ]; };
              bashls = { cmd = [ ("${bashls}/bash-language-server") ]; };
              clangd = { cmd = [ ("${pkgs.clang-tools}/bin/clangd") ]; };
              cmake = { cmd = [ (bp pkgs.cmake-language-server) ]; };
              cssls = { cmd = [ ("${vscode-ls}/vscode-css-language-server") ]; };
              dockerls = { cmd = [ "${dockerls}/docker-langserver" ]; };
              dotls = { cmd = [ (bp pkgs.dot-language-server) ]; };
              eslint = { cmd = [ ("${vscode-ls}/vscode-eslint-language-server") ]; };
              gopls = { cmd = [ (bp pkgs.gopls) ]; };
              html = { cmd = [ ("${vscode-ls}/vscode-html-language-server") ]; };
              jsonls = { cmd = [ ("${vscode-ls}/vscode-json-language-server") ]; };
              lua_ls = { cmd = [ (bp pkgs.lua-language-server) ]; };
              marksman = { cmd = [ (bp pkgs.marksman) ]; };
              nil_ls = { cmd = [ (bp pkgs.nil) ]; };
              nushell = { cmd = [ (bp pkgs.nushell) ]; };
              omnisharp = { cmd = [ (bp pkgs.omnisharp-roslyn) ]; };
              perlls = { cmd = [ (bp pkgs.perlPackages.PerlLanguageServer) ]; }; # broken
              postgres_lsp = { cmd = [ (bp pkgs.postgres-lsp) ]; };
              psalm = { cmd = [ (bp pkgs.phpPackages.psalm) ]; };
              pyright = { cmd = [ ("${pyright}/pyright-langserver") ]; };
              ruby_ls = { cmd = [ (bp pkgs.ruby-lsp) ]; };
              rust_analyzer = { cmd = [ (bp pkgs.rust-analyzer) ]; };
              terraformls = { cmd = [ (bp pkgs.terraform-ls) ]; };
              tflint = { cmd = [ (bp pkgs.tflint) ]; };
              tsserver = { cmd = [ ("${tsserver}/typescript-language-server") ]; };
              typos_lsp = { cmd = [ ("${pkgs.typos-lsp}/bin/typos-lsp") ]; };
              vimls = { cmd = [ ("${vimls}/vimls-language-server") ]; };
              yamlls = { cmd = [ ("${yamlls}/yaml-language-server") ]; };
              zls = { cmd = [ (bp pkgs.zls) ]; };
            };
          fmt =
            let
              mkConform = path: { command = path; };
            in
            builtins.mapAttrs (key: mkConform) {
              clang_format = "${pkgs.clang-tools}/bin/clang-format";
              deno_fmt = bp pkgs.deno;
              fish_indent = "${pkgs.fish}/bin/fish_indent";
              fixjson = "${nodeLatest.fixjson}/bin/fixjson";
              gofmt = "${pkgs.go}/bin/gofmt";
              goimports = "${pkgs.gotools}/bin/goimports";
              golines = "${pkgs.golines}/bin/golines";
              nixpkgs_fmt = bp pkgs.nixpkgs-fmt;
              packer_fmt = bp pkgs.packer;
              prettierd = bp pkgs.prettierd;
              ruff_fix = bp pkgs.ruff;
              ruff_format = bp pkgs.ruff;
              rustfmt = bp pkgs.rustfmt;
              shellcheck = bp pkgs.shellcheck;
              stylua = bp pkgs.stylua;
              taplo = bp pkgs.taplo;
              terraform_fmt = bp pkgs.terraform;
              terragrunt_hclfmt = bp pkgs.terragrunt;
              yamlfmt = bp pkgs.yamlfmt;
              yamlfix = bp pkgs.yamlfix;
            };
          repl = {
            lua = { command = [ (bp pkgs.lua) ]; };
          };
          tools = {
            paths = {
              ripgrep = bp pkgs.ripgrep;
            };
          };
          ui = {
            # For Neovide
            font = {
              inherit (fonts.monospace) name;
              size = fonts.sizes.terminal;
            };
          };
        };
        luaConfig = lib.generators.toLua { } config;
      in
        /* lua */
      "require('init').setup(${luaConfig})";
  };
}
