{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
{
  flake.repl =
    let
      host = builtins.getEnv "HOST";
      user = builtins.getEnv "USER";
    in
    rec {
      pkgs = withSystem builtins.currentSystem ({ pkgs, ... }: pkgs);
      fmt = inputs.treefmt-nix.lib.evalModule pkgs ../fmt/default.nix;
      lib = pkgs.lib;
      inherit self inputs;

      os = self.nixosConfigurations.${host} or { };
      home = self.homeConfigurations."${user}@${host}" or { };
    };
}
