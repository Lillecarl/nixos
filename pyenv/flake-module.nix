{ self
, inputs
, withSystem
, flakeloc
, ...
}:
{
  perSystem =
    { pkgs
    , ...
    }:
    {
      devShells.pyenv = pkgs.mkShell {
        packages = [
          pkgs.pokemonsay
          (pkgs.python3.withPackages (ps: with ps; [
            plumbum
          ]))
        ];

        shellHook = ''
          exec $SHELL
        '';
      };
    };
}
