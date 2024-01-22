{ pkgs
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
                bashls = "${nodeLatest.bash-language-server}/bin";
                dockerls = "${nodeLatest.dockerfile-language-server-nodejs}/bin";
                pyright = "${nodeLatest.pyright}/bin";
                tsserver = "${nodeLatest.typescript-language-server}/bin";
                vimls = "${nodeLatest.vim-language-server}/bin";
                vscode-ls = "${nodeLatest.vscode-langservers-extracted}/bin";
                yamlls = "${nodeLatest.yaml-language-server}/bin";

                mkLsp = path: { cmd = [ path ]; };
              in
              {
                # TODO: PowerShell
                ansiblels = mkLsp (bp pkgs.ansible-language-server);
                bashls = mkLsp "${bashls}/bash-language-server";
                clangd = mkLsp "${pkgs.clang-tools}/bin/clangd";
                cmake = mkLsp (bp pkgs.cmake-language-server);
                cssls = mkLsp "${vscode-ls}/vscode-css-language-server";
                dockerls = mkLsp "${dockerls}/docker-langserver";
                dotls = mkLsp (bp pkgs.dot-language-server);
                eslint = mkLsp "${vscode-ls}/vscode-eslint-language-server";
                gopls = mkLsp (bp pkgs.gopls);
                html = mkLsp "${vscode-ls}/vscode-html-language-server";
                jsonls = mkLsp "${vscode-ls}/vscode-json-language-server";
                lua_ls = mkLsp (bp pkgs.lua-language-server);
                marksman = mkLsp (bp pkgs.marksman);
                nil_ls = mkLsp (bp pkgs.nil);
                nixd = mkLsp (bp pkgs.nixd);
                nushell = mkLsp (bp pkgs.nushell);
                omnisharp = mkLsp (bp pkgs.omnisharp-roslyn);
                perlls = mkLsp (bp pkgs.perlPackages.PerlLanguageServer); # broken
                postgres_lsp = mkLsp (bp pkgs.postgres-lsp);
                psalm = mkLsp (bp pkgs.phpPackages.psalm);
                pyright = mkLsp "${pyright}/pyright-langserver";
                ruby_ls = mkLsp (bp pkgs.ruby-lsp);
                rust_analyzer = mkLsp (bp pkgs.rust-analyzer);
                terraformls = mkLsp (bp pkgs.terraform-ls);
                tsserver = mkLsp "${tsserver}/typescript-language-server";
                vimls = mkLsp "${vimls}/vimls-language-server";
                yamlls = mkLsp "${yamlls}/yaml-language-server";
                zls = mkLsp (bp pkgs.zls);
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
