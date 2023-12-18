{ pkgs
, lib
, ...
}:
{
  home.packages = [
    pkgs.tree-sitter # for TS troubleshooting
  ];

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
      pkgs.stylua
      pkgs.nixpkgs-fmt # formatting for nil
    ];

    plugins = with pkgs.vimPlugins; [
      #camelcasemotion
      #catppuccin-nvim
      #cmp-nvim-lsp # LSP source for cmp
      #copilot-lua
      #formatter-nvim
      #fugitive
      #indent-blankline-nvim
      #neodev-nvim
      #neogit
      #nvim-cmp
      #nvim-lspconfig
      #nvim-snippy
      #nvim-tree-lua
      #nvim-treesitter.withAllGrammars
      #surround
      #tabby-nvim
      #tabmerge
      #telescope-nvim
      #toggleterm-nvim
      #vim-airline
      #which-key-nvim
      #LazyVim
      lazy-nvim
    ];

    extraLuaConfig = let lazyPlugins = [
      { name = "nvim-treesitter/nvim-treesitter"; dir = pkgs.vimPlugins.nvim-treesitter.withAllGrammars; }
      { name = "folke/which-key"; dir = pkgs.vimPlugins.which-key-nvim; }
    ]; in /* lua */ ''
      ${"\n"}--[[
      require('user_config')
      require('catppuccin_config')
      require('copilot_config')
      require('neogit_config')
      require('telescope_config')
      require('toggleterm_config')
      require('lsp_config')
      require('nvim-tree_config')
      require('formatter_config')
      require('treesitter_config')
      require("config.lazy").setup('${pkgs.vimPlugins.LazyVim}')
      require("config.lazy").setup({
      ${lib.concatMapStrings (x: "  { name = \"${x.name}\", dir = \"${x.dir}\" },\n") lazyPlugins}
      })--]]
      require("config.lazy")
    '';
  };
}
