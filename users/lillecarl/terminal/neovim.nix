{
  lib,
  pkgs,
  config,
  ...
}:
let
  modName = "neovim";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = config.programs.helix.extraPackages ++ [
        pkgs.nodejs # Copilot
        pkgs.lua-language-server
        pkgs.basedpyright
      ];

      plugins = with pkgs.vimPlugins; [
        lze # Lazy loader that quacks a bit like lazy.nvim
        multicursors-nvim # Feeling a bit heelixy?
        which-key-nvim # Show keybindings
        nvim-treesitter.withAllGrammars # Syntax highlighting for humans
        catppuccin-nvim # Theme
        mini-nvim # Collection of essential features
        indent-blankline-nvim # Indent guides
        nvim-web-devicons # Icons
        conform-nvim # Formatting master
        nvim-lspconfig # LSP configuration tool
        copilot-lua # GH Copilot for Neovim
        CopilotChat-nvim # GH Copilot chat for Neovim
        plenary-nvim # curl, log, async
        gitsigns-nvim # Git gutters
        luasnip # Snippets
        nvim-cmp # Completion
        cmp-nvim-lsp
        cmp-git
        cmp-path
        cmp-buffer
        cmp-cmdline
        cmp_luasnip
      ];

      extraLuaConfig =
        let
          luaConfig = {

          };
        in
        # lua
        ''
          require("luainit").setup(${lib.generators.toLua { } luaConfig})
        '';
    };
  };
}
