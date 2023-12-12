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

    plugins = with pkgs.vimPlugins; [
      camelcasemotion
      catppuccin-nvim
      coc-clangd
      coc-pyright
      copilot-lua
      ctrlp
      fugitive
      indent-blankline-nvim
      neodev-nvim
      neogit
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      surround
      tabby-nvim
      tabmerge
      telescope-nvim
      toggleterm-nvim
      vim-airline
      vim-tmux-navigator
      which-key-nvim
    ];

    coc = {
      enable = true;

      settings = {
        languageserver = {
          nix = {
            command = bp pkgs.nil;
            filetypes = [ "nix" ];
            rootPatterns = [ "flake.nix" ];
            settings = {
              nil = {
                formatting = { command = [ (bp pkgs.nixpkgs-fmt) ]; };
              };
            };
          };
          terraform = {
            command = bp pkgs.terraform-lsp;
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

    extraLuaConfig = ''${"\n"}
      require('user_config')
      require('catppuccin_config')
      require('coc_config')
      require('copilot_config')
      require('neogit_config')
      require('telescope_config')
      require('toggleterm_config')
    '';
  };
}
