{ pkgs
, bp
, ...
}:
{
  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    extraPackages = [
      pkgs.clang-tools # C, C++ lsp
      pkgs.fd # for telescope
      pkgs.lua-language-server # lua lsp
      pkgs.nil # nix lsp
      pkgs.ripgrep # for telescope
      pkgs.terraform-lsp # terraform lsp
      pkgs.pyright # python lsp
    ];

    plugins = with pkgs.vimPlugins; [
      camelcasemotion
      catppuccin-nvim
      cmp-nvim-lsp # LSP source for cmp
      copilot-lua
      fugitive
      indent-blankline-nvim
      neodev-nvim
      neogit
      nvim-cmp
      nvim-lspconfig
      nvim-snippy
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      surround
      tabby-nvim
      tabmerge
      telescope-nvim
      toggleterm-nvim
      vim-airline
      which-key-nvim
    ];

    extraLuaConfig = ''${"\n"}
      require('user_config')
      require('catppuccin_config')
      require('copilot_config')
      require('neogit_config')
      require('telescope_config')
      require('toggleterm_config')
      require('lsp_config')
    '';
  };
}
