{ pkgs
, lib
, inputs
, ...
}:
let
  font = "Hack Nerd Font";
  fromYAML = src: builtins.fromJSON (builtins.readFile (pkgs.stdenvNoCC.mkDerivation {
    name = "fromYAML";

    inherit src;
    preferLocalBuild = true;
    allowSubstitutes = false;

    buildCommand = ''
      cat $src | ${pkgs.yj}/bin/yj -i > $out
    '';
  }));
in
{
  programs.alacritty = {
    enable = true;
  };
}
