{ pkgs
, ...
}:
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
    ] ++ [
      # lsp servers
      pkgs.clang-tools # C, C++
      pkgs.lua-language-server # Lua
      pkgs.nil # Nix
      pkgs.terraform-ls # Terraform
      pkgs.pyright # Python
      pkgs.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
    ] ++ [
      # code formatters
      pkgs.isort # sort python imports
      pkgs.black # python formatter
      pkgs.stylua # lua formatter
      pkgs.nodePackages.prettier # web formatter
      pkgs.nixpkgs-fmt # formatting for nil
      pkgs.terraform # terraform formatter
      pkgs.terragrunt # terraform formatter
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
      indent-blankline-nvim
      luasnip
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
      telescope-nvim
      trouble-nvim
      which-key-nvim
    ];

    extraLuaConfig =
      /* lua */ ''
      ${"\n"}
      require('init').setup({})
    '';
  };
}
