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
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.pokemonsay
          pkgs.msr-tools
          (pkgs.python3.withPackages (ps: with ps; [
            PyGithub
            levenshtein
            plumbum
            psutil
            requests
            textual
          ]))
        ];

        shellHook = ''
        '';
      };
    };
}
