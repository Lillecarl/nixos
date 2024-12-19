{ lib, config, ... }:
let
  modName = "fd";
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
    xdg.configFile."fd/ignore".text = ''
      .git
      .hg
      .svn
      .stack-work
      .idea
      .vscode
      .vagrant
      .DS_Store
      .cabal-sandbox
      cabal.sandbox.config
      .vagrant
      .stack-work
    '';
  };
}
