{
  self,
  inputs,
  __curPos ? __curPos,
  ...
}:
{
  perSystem =
    { system, pkgs, ... }:
    {
      checks.pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ../.;
        #src = ./.;
        hooks = {
          nixfmt-rfc-style.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    };
}
