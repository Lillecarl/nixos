{ pkgs
, bp
, ...
}:
let
  fromYAML = src: builtins.fromJSON (builtins.readFile (pkgs.stdenvNoCC.mkDerivation {
    name = "fromYAML";

    inherit src;
    preferLocalBuild = true;
    allowSubstitutes = false;

    buildCommand = ''
      cat $src | ${bp pkgs.yj} -i > $out
    '';
  }));
in
{
  programs.alacritty = {
    enable = true;
  };
}
