{ pkgs
, ...
}:
{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
  };
}
