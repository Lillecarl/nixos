{ ... }:
{
  programs.ripgrep = {
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
