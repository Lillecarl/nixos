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
    let
      repoenv = pkgs.mkShell {
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
    in
    {
      devShells.default = repoenv;
      devShells.repoenv = repoenv;
    };
}
