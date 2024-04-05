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
            fuse
            jinja2
            levenshtein
            plumbum
            psutil
            python-gitlab
            pywayland
            pywlroots
            requests
            sh
            textual
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
