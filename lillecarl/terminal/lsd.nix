{ ... }:
{
  programs.lsd = {
    enable = true;

    enableAliases = true;

    settings = {
      icons = {
        theme = "fancy";
      };
      recursion = {
        enabled = true;
        depth = 2;
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
