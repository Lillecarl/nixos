{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "jj";
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
    programs.jujutsu =
      let
        gitSettings = config.programs.git.settings;
      in
      {
        enable = true;
        settings = {
          ui.diff-editor = ":builtin";
          git.private-commits = "'''description(glob:'private:*')'''";
        }
        // {
          inherit (gitSettings) user;
        };
      };
    programs.jjui = {
      enable = true;
      settings = { };
    };
  };
}
