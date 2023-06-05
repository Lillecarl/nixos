{ self
, config
, pkgs
, inputs
, ...
}:
let
  nil = inputs.nil.packages."x86_64-linux".default;
  luaPath = "${config.home.homeDirectory}/.config/nvim/lua/";
in
{
  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    #defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      coc-clangd
      coc-pyright
      copilot-lua
      ctrlp
      fugitive
      nerdtree
      nvim-treesitter
      surround
      vim-airline
      vim-nix
      vim-nftables
    ];

    coc = {
      enable = true;

      settings = {
        languageserver = {
          #nix = {
          #  command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
          #  filetypes = [ "nix" ];
          #};
          nix = {
            command = "${nil}/bin/nil";
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
            filetypes = [ "c" "cc" "cpp" "c++" "objc" "objcpp" ];
          };
        };
      };
    };

    extraConfig = ''
      set mouse=
      set number
      set encoding=utf-8
      set ignorecase
      set smartcase
    '';

    extraLuaConfig = ''
    '';
  };

  xdg.configFile = {
    "nvim/lua/.keep" = { text = "keep"; };
  };

  systemd.user.tmpfiles.rules = [
    "L ${luaPath}/init.lua - - - - ${self}/lillecarl/terminal/neovim/lua/init.lua"
  ];
}
