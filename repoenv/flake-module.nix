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
            evdev
            levenshtein
            plumbum
            psutil
            python-gitlab
            requests
            textual
          ]))
        ];

        shellHook = ''
        '';
      };
      devShells.default = devShells.repoenv;
    };
}
