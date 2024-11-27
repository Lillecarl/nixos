{ self
, inputs
, __curPos ? __curPos
, ...
}:
{
  flake.repl =
    let
      host = builtins.getEnv "HOST";
      user = builtins.getEnv "USER";
    in
    rec {
      pkgs = (
        self.nixosConfigurations.${host} or
          self.homeConfigurations."${user}@${host}"
      ).pkgs;
      lib = pkgs.lib;

      os = self.nixosConfigurations.${host} or { };
      home = self.homeConfigurations."${user}@${host}" or { };
    };
}
