{ lib, config, ... }:
{
  programs.lsd = lib.mkIf config.ps.terminal.enable {
    enable = true;

    enableAliases = true;

    settings = {
      icons = {
        theme =
          if config.ps.terminal.nerdfonts == true then
            "fancy"
          else
            "unicode";
      };
      permission = "octal";
      sorting = {
        dir-grouping = "first";
      };
      ignore-globs = [
        ".git"
      ];
    };
  };
}
