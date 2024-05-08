_:
{
  perSystem =
    { pkgs
    , ...
    }:
    let
      farm = pkgs.symlinkJoin {
        name = "repoenv-farm";
        paths = [
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
            qutebrowser
          ]))
        ];
      };
      repoenv = pkgs.mkShell {
        packages = [ farm ];

        shellHook = ''
        '';
      };
    in
    {
      devShells.default = repoenv;
      devShells.repoenv = repoenv;
      packages.repofarm = farm;
    };
}
