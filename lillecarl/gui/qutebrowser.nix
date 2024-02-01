{ pkgs
, ...
}:
{
  home.packages = [
    pkgs.keyutils
  ];
  programs.qutebrowser = {
    enable = true;
  };
}
