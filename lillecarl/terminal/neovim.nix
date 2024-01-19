{ pkgs
, lib
, bp
, config
, ...
}:
let
  fonts = config.stylix.fonts;
in
{
  home.packages = [
    pkgs.tree-sitter # for TS troubleshooting
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
      catppuccin-nvim
      cmp-git # git source for cmp
      cmp-nvim-lsp # LSP source for cmp
      conform-nvim
      copilot-lua
      fugitive
      gitsigns-nvim
      indent-blankline-nvim
      luasnip
      neoconf-nvim
      neodev-nvim
      noice-nvim
      nui-nvim
      nvim-autopairs
      nvim-cmp
      nvim-lspconfig
      nvim-notify
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      overseer-nvim
      telescope-nvim
      trouble-nvim
      which-key-nvim
    ];

    extraLuaConfig =
      let
        nodeLatest = pkgs.nodePackages_latest;
        config = {
          lsp = {
            paths =
              let
                bashls = "${nodeLatest.pyright}/bin";
                dockerls = "${nodeLatest.dockerfile-language-server-nodejs}/bin";
                pyright = "${nodeLatest.pyright}/bin";
                tsserver = "${nodeLatest.typescript-language-server}/bin";
                vimls = "${nodeLatest.vim-language-server}/bin";
                vscode-ls = "${nodeLatest.vscode-langservers-extracted}/bin";
                yamlls = "${nodeLatest.yaml-language-server}/bin";
              in
              {
                # TODO: PowerShell
                ansiblels = bp pkgs.ansible-language-server;
                bashls = "${bashls}/bash-language-server";
                clangd = "${pkgs.clang-tools}/bin/clangd";
                cmake = bp pkgs.cmake-language-server;
                cssls = "${vscode-ls}/vscode-css-language-server";
                dockerls = "${dockerls}/docker-langserver";
                dotls = bp pkgs.dot-language-server;
                eslint = "${vscode-ls}/vscode-eslint-language-server";
                gopls = bp pkgs.gopls;
                html = "${vscode-ls}/vscode-html-language-server";
                jsonls = "${vscode-ls}/vscode-json-language-server";
                lua_ls = bp pkgs.lua-language-server;
                marksman = bp pkgs.marksman;
                nil_ls = bp pkgs.nil;
                nixd = bp pkgs.nixd;
                nushell = bp pkgs.nushell;
                omnisharp = bp pkgs.omnisharp-roslyn;
                perlls = bp pkgs.perlPackages.PerlLanguageServer; # broken
                postgres_lsp = bp pkgs.postgres-lsp;
                psalm = bp pkgs.phpPackages.psalm;
                pyright = "${pyright}/typescript-language-server";
                ruby_ls = bp pkgs.ruby-lsp;
                rust_analyzer = bp pkgs.rust-analyzer;
                terraformls = pkgs.terraform-ls;
                tsserver = "${tsserver}/typescript-language-server";
                vimls = "${vimls}/vimls-language-server";
                yamlls = "${yamlls}/yaml-language-server";
                zls = bp pkgs.zls;
              };
          };
          fmt = {
            paths = {
              black = bp pkgs.black;
              clang_format = "${pkgs.clang-tools}/bin/clang-format";
              isort = bp pkgs.isort;
              nixpkgs_fmt = bp pkgs.nixpkgs-fmt;
              fixjson = "${nodeLatest.fixjson}/bin/fixjson";
              packer_fmt = bp pkgs.packer;
              prettier = "${nodeLatest.prettier}/bin/prettier";
              rustfmt = bp pkgs.rustfmt;
              shellcheck = bp pkgs.shellcheck;
              stylua = bp pkgs.stylua;
              terraform_fmt = bp pkgs.terraform;
              terragrunt_fmt = bp pkgs.terragrunt;
              yamlfmt = "${pkgs.clang-tools}/bin/yamlfmt";
            };
          };
          tools = {
            paths = {
              ripgrep = bp pkgs.ripgrep;
            };
          };
          ui = {
            # For Neovide
            font = {
              name = fonts.monospace.name;
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
