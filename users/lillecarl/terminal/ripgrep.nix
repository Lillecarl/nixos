{ lib, config, ...}:
{
  programs.ripgrep = lib.mkIf config.ps.terminal.enable {
    enable = true;

    arguments = [
      "--hidden"
      "--follow"
      "--smart-case"
      "--max-columns=200"
      "--max-columns-preview"
      "--glob=!.git/*"
    ];
  };
}
