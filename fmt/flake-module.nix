{
  self,
  inputs,
  __curPos ? __curPos,
  ...
}:
{
  perSystem =
    { system, pkgs, ... }:
    let
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./default.nix;
    in
    {
      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check;
    };
}
