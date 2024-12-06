{ lib, config, ... }:
{
  programs.helix = lib.mkIf config.ps.editors.enable {
    enable = config.ps.editors.enable;
    defaultEditor = true;

    settings = {
      theme = if config.ps.terminal.true-color then "catppuccin_mocha" else "default";
      editor = {
        true-color = config.ps.terminal.true-color;
        indent-guides.render = true;
        rulers = [ 80 ];
        bufferline = "always";
        color-modes = true;
      };
      keys = {
        normal = {
          "C-s" = ":w";
        };
        insert = {
          "C-s" = ":w";
          "C-space" = "completion";
        };
      };
    };
  };
}
