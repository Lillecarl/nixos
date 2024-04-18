_:
{
  programs.fish = {
    enable = true;

    useBabelfish = true;

    vendor = {
      completions.enable = true;
      config.enable = true;
      functions.enable = true;
    };
  };
}
