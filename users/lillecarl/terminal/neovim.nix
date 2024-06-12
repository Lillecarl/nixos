{ pkgs
, lib
, config
, ...
}:
let
  inherit (config.stylix) fonts;
in
{
  home.packages = [
    pkgs.tree-sitter # for TS troubleshooting
    config.lib.nvimpager
  ];

  stylix.targets.vim.enable = false;

  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    extraPython3Packages = ps: with ps; [
      python-dotenv
      requests
      prompt-toolkit
      tiktoken
    ];

    extraPackages = with pkgs; [
      # lsp
      clang-tools
      cmake-language-server
      dot-language-server
      gopls
      lua-language-server
      marksman
      nil
      pyright
      # fmt
      deno # deno fmt
      fish # fish_indent
      nodePackages_latest.bash-language-server
      nodePackages_latest.dockerfile-language-server-nodejs
      nodePackages_latest.fixjson
      nodePackages_latest.typescript-language-server
      nodePackages_latest.vim-language-server
      nodePackages_latest.vscode-langservers-extracted # HTML, CSS, ESLint, JSON
      nodePackages_latest.yaml-language-server
      nushell
      omnisharp-roslyn
      phpPackages.psalm
      postgres-lsp
      ruby-lsp
      rust-analyzer
      statix
      terraform-ls
      tflint
      typos-lsp
      zls
      go # gofmt
      gotools # goimports, golines
      nixpkgs-fmt
      packer # packer fmt
      prettierd
      ruff
      rustfmt
      shellcheck
      stylua
      taplo
      terragrunt # terragrunt hclfmt
      yamlfmt
      # misc tools
      fd # for telescope
      ripgrep # for telescope
      tree-sitter # silence tree-sitter warning
      fzf # fuzzy finder
      git # Gitsigns, Fugitive
      cargo # for rust-analyzer
      nodePackages.nodejs # For copilot
      pkgs.copilotchat-nvim # python3 with copilotchat
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
      (pkgs.vimUtils.buildVimPlugin {
        pname = "nvimpager";
        inherit (pkgs.nvimpager.drvAttrs) version;

        inherit (pkgs.nvimpager) src;
      })
      pkgs.copilotchat-nvim
      aerial-nvim
      SchemaStore-nvim
      cmp-git
      cmp-nvim-lsp
      conform-nvim
      copilot-lua
      fugitive
      gitsigns-nvim
      indent-blankline-nvim
      iron-nvim
      leap-nvim
      luasnip
      neoconf-nvim
      neodev-nvim
      noice-nvim
      nui-nvim
      nvim-autopairs
      nvim-cmp
      nvim-dap
      nvim-dap-python
      nvim-dap-ui
      nvim-lspconfig
      nvim-notify
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      overseer-nvim
      playground
      repeat
      telescope-nvim
      trouble-nvim
      which-key-nvim
    ] ++ [
      pkgs.one-small-step-for-vimkind
    ];
    extraLuaPackages = ps: with ps; [
      nvim-nio
      tiktoken_core
    ];

    extraLuaConfig =
      let
        nodeLatest = pkgs.nodePackages_latest;
        config = {
          lsp =
            let
              bashls = "${nodeLatest.bash-language-server}/bin";
              dockerls = "${nodeLatest.dockerfile-language-server-nodejs}/bin";
              pyright = "${pkgs.pyright}/bin";
              tsserver = "${nodeLatest.typescript-language-server}/bin";
              vimls = "${nodeLatest.vim-language-server}/bin";
              vscode-ls = "${nodeLatest.vscode-langservers-extracted}/bin";
              yamlls = "${nodeLatest.yaml-language-server}/bin";

            in
            {
              # TODO: PowerShell
              # Ansible looks a bit complicated, but we build a Python with Ansible
              # and we farm them together with the Ansible CLI tools.
              ansiblels =
                let
                  ansibleLspFarm = pkgs.symlinkJoin {
                    name = "ansiPy";
                    paths = [
                      (pkgs.python3.withPackages (ps: [
                        ps.ansible
                      ]))
                      pkgs.ansible
                      pkgs.ansible-lint
                      pkgs.ansible-language-server
                    ];
                  };
                in
                {
                  cmd = [ "${ansibleLspFarm}/bin/ansible-language-server" "--stdio" ];
                  settings = {
                    ansible = {
                      ansible.path = "${ansibleLspFarm}/bin/ansible";
                      python.interpreterPath = "${ansibleLspFarm}/bin/python3";
                      validation.lint.path = "${ansibleLspFarm}/bin/ansible-lint";
                    };
                  };
                  nodefault = true;
                };
              #statix = { cmd = [ (lib.getExe pkgs.statix) ]; };
              bashls = { cmd = [ "${bashls}/bash-language-server" ]; };
              clangd = { cmd = [ "${pkgs.clang-tools}/bin/clangd" ]; };
              cmake = { cmd = [ (lib.getExe pkgs.cmake-language-server) ]; };
              cssls = { cmd = [ "${vscode-ls}/vscode-css-language-server" ]; };
              dockerls = { cmd = [ "${dockerls}/docker-langserver" ]; };
              dotls = { cmd = [ (lib.getExe pkgs.dot-language-server) ]; };
              eslint = { cmd = [ "${vscode-ls}/vscode-eslint-language-server" ]; };
              gopls = { cmd = [ (lib.getExe pkgs.gopls) ]; };
              html = { cmd = [ "${vscode-ls}/vscode-html-language-server" ]; };
              jsonls = { cmd = [ "${vscode-ls}/vscode-json-language-server" ]; };
              lua_ls = { cmd = [ (lib.getExe pkgs.lua-language-server) ]; };
              marksman = { cmd = [ (lib.getExe pkgs.marksman) ]; };
              nil_ls = { cmd = [ (lib.getExe pkgs.nil) ]; };
              nushell = { cmd = [ (lib.getExe pkgs.nushell) ]; };
              omnisharp = { cmd = [ (lib.getExe pkgs.omnisharp-roslyn) ]; };
              postgres_lsp = { cmd = [ (lib.getExe pkgs.postgres-lsp) ]; };
              psalm = { cmd = [ (lib.getExe pkgs.phpPackages.psalm) ]; };
              pyright = { cmd = [ "${pyright}/pyright-langserver" ]; };
              ruby_lsp = { cmd = [ (lib.getExe pkgs.ruby-lsp) ]; };
              rust_analyzer = { cmd = [ (lib.getExe pkgs.rust-analyzer) ]; };
              terraformls = { cmd = [ (lib.getExe pkgs.terraform-ls) ]; };
              tflint = { cmd = [ (lib.getExe pkgs.tflint) ]; };
              tsserver = { cmd = [ "${tsserver}/typescript-language-server" ]; };
              typos_lsp = { cmd = [ "${pkgs.typos-lsp}/bin/typos-lsp" ]; };
              vimls = { cmd = [ "${vimls}/vimls-language-server" ]; };
              yamlls = { cmd = [ "${yamlls}/yaml-language-server" ]; };
              zls = { cmd = [ (lib.getExe pkgs.zls) ]; };
            };
          fmt =
            let
              mkConform = path: { command = path; };
            in
            builtins.mapAttrs (key: mkConform) {
              clang_format = "${pkgs.clang-tools}/bin/clang-format";
              deno_fmt = lib.getExe pkgs.deno;
              fish_indent = "${pkgs.fish}/bin/fish_indent";
              fixjson = "${nodeLatest.fixjson}/bin/fixjson";
              gofmt = "${pkgs.go}/bin/gofmt";
              goimports = "${pkgs.gotools}/bin/goimports";
              golines = "${pkgs.golines}/bin/golines";
              nixpkgs_fmt = lib.getExe pkgs.nixpkgs-fmt;
              packer_fmt = "${pkgs.packer}/bin/packer";
              prettierd = lib.getExe pkgs.prettierd;
              ruff_fix = lib.getExe pkgs.ruff;
              ruff_format = lib.getExe pkgs.ruff;
              rustfmt = lib.getExe pkgs.rustfmt;
              shellcheck = lib.getExe pkgs.shellcheck;
              stylua = lib.getExe pkgs.stylua;
              taplo = lib.getExe pkgs.taplo;
              terraform_fmt = lib.getExe pkgs.terraform;
              terragrunt_hclfmt = lib.getExe pkgs.terragrunt;
              yamlfmt = lib.getExe pkgs.yamlfmt;
            };
          repl = {
            lua = { command = [ "${pkgs.lua}/bin/lua" ]; };
          };
          tools = {
            paths = {
              ripgrep = lib.getExe pkgs.ripgrep;
              copilotchatPython = "${pkgs.copilotchat-nvim}/bin/python3";
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

  lib.nvimpager = pkgs.nvimpager.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
