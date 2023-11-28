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
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
      ];
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
        pkgs.keyutils
      ];
    });
  };
}
