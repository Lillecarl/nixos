{ pkgs
, ...
}:
{
  home.packages = [
    pkgs.keyutils
  ];
  programs.qutebrowser = {
    enable = true;

    package = pkgs.qutebrowser.overrideAttrs (oldAttrs: {
      inherit (oldAttrs) propagatedBuildInputs;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
        pkgs.keyutils
      ];
    });
  };
}
