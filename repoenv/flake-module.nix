_:
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
            deepmerge
            evdev
            levenshtein
            plumbum
            psutil
            python-gitlab
            requests
            textual
            pywlroots
            pywayland
          ]))
          pkgs.python3.pkgs.pywayland
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
