_:
{
  programs.lsd = {
    enable = true;

    enableAliases = true;

    settings = {
      icons = {
        theme = "fancy";
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
