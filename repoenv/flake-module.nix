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
    rec {
      devShells.repoenv = pkgs.mkShell {
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
            python-gitlab
          ]))
        ];

        shellHook = ''
        '';
      };
      devShells.default = devShells.repoenv;
    };
}
