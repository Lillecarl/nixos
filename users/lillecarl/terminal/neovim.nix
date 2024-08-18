{ pkgs
, lib
, config
, nixosConfig
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

  home.sessionVariables = {
    # Use NeoVim for sudo edits, but without plugins and muck
    SUDO_EDITOR = lib.getExe pkgs.neovim;
  };

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
      jsonnet-language-server
      # fmt
      deno # deno fmt
      fish # fish_indent
      bash-language-server
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

    extraLuaConfig = let
      config = {
      ui = {
        # For Neovide
        font = {
          inherit (fonts.monospace) name;
          size = fonts.sizes.terminal;
        };
      };
      };
    in
    ''

      require('init').setup(${lib.generators.toLua {} config})
    '';
  };

  lib.nvimpager = pkgs.nvimpager.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
