{ pkgs
, lib
, config
, nixosConfig
, inputs
, self
, ...
}:
let
  nixvim = inputs.nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
    inherit pkgs;
    module = {
      # Import nixvim config
      imports = [ "${self}/nixvim/default.nix" ];
      config = {
        # HM specific options here
      };
    };
    extraSpecialArgs = { };
  };

  nvimpager = pkgs.nvimpager.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
in
{
  home.packages = [
    nixvim
    nvimpager
    pkgs.tree-sitter # for TS troubleshooting
  ];

  home.sessionVariables = {
    # Use NeoVim for sudo edits, but without plugins and muck
    SUDO_EDITOR = lib.getExe pkgs.neovim;
  };

  programs.neovim.enable = false;

  lib = {
    inherit
      nixvim
      nvimpager
    ;
  };
}
