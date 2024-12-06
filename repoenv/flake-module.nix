_: {
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      farm = pkgs.symlinkJoin {
        name = "repoenv-farm";
        paths = [
          pkgs.pokemonsay
          pkgs.msr-tools
          pkgs.pre-commit
          (pkgs.python3.withPackages (
            ps: with ps; [
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
              qemu-qmp
              libvirt
            ]
          ))
          (pkgs.writeScriptBin "terragrunt" # bash
            ''
              #! ${pkgs.runtimeShell}

              exec ${pkgs.lib.getExe pkgs.terragrunt} --terragrunt-tfpath ${pkgs.lib.getExe pkgs.opentofu} "$@"
            ''
          )
        ];
      };
    in
    {
      packages.repofarm = farm;
    };
}
