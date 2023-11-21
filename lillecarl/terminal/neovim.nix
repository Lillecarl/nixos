{ pkgs
, ...
}:
{
  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # toggleterm-nvim # TODO: fix
      catppuccin-nvim
      coc-clangd
      coc-pyright
      copilot-lua
      ctrlp
      fugitive
      neodev-nvim
      neogit
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      surround
      tabby-nvim
      tabmerge
      telescope-nvim
      vim-airline
      vim-tmux-navigator
      which-key-nvim
    ];

    coc = {
      enable = true;

      settings = {
        languageserver = {
          nix = {
            command = "${pkgs.nil}/bin/nil";
            filetypes = [ "nix" ];
            rootPatterns = [ "flake.nix" ];
            settings = {
              nil = {
                formatting = { command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ]; };
              };
            };
          };
          terraform = {
            command = "${pkgs.terraform-lsp}/bin/terraform-lsp";
            filetypes = [ "terraform" ];
            initializationOptions = { };
          };
          clangd = {
            command = "${pkgs.clang-tools}/bin/clangd";
            rootPatterns = [ "compile_flags.txt" "compile_commands.json" ];
            filetypes = [ "c" "cc" "cpp" "c++" "objc" "objcpp" "h" "hpp" ];
          };
        };
      };
    };

    extraConfig = ''
      " is comments in this language
      " <leader> = "\" (hold)

      set mouse=
      set number
      set encoding=utf-8
      set ignorecase
      set smartcase

      " " Copy to clipboard
      vnoremap  <leader>y  "+y
      nnoremap  <leader>Y  "+yg_
      nnoremap  <leader>y  "+y
      nnoremap  <leader>yy "+yy

      " " Paste from clipboard
      nnoremap <leader>p "+p
      nnoremap <leader>P "+P
      vnoremap <leader>p "+p
      vnoremap <leader>P "+P
    '';

    extraLuaConfig = ''
      ${"\n"}-- Configure coc
      require('catppuccin_config')
      require('coc_config')
      require('copilot_config')
      require('neogit_config')
      require('telescope_config')
      require('user_config')
    '';
  };
}
