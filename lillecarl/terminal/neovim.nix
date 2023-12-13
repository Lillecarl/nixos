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
      pkgs.clang-tools # C, C++
      pkgs.fd # For telescope
      pkgs.lua-language-server #Lua
      pkgs.nil # Nix
      pkgs.ripgrep # For telescope
      pkgs.terraform-lsp # Terraform
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

    coc = {
      enable = false;

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
      require('copilot_config')
      require('neogit_config')
      require('telescope_config')
      require('toggleterm_config')
      require('lsp_config')
      --require('coc_config')
    '';
  };
}
