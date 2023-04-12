{ python3
, symlinkJoin
, xonsh
, xonsh-wrapper
, lib
}:
symlinkJoin {
  name = "xonsh-joined";
  # recurse all listed dependencies
  paths = with python3.pkgs; (python3.pkgs.requiredPythonModules [
    coconut
    (lib.hiPrio xonsh-wrapper)
    PyGithub
    from_ssv
    jinja2
    kubernetes
    lazyasd
    munch
    plumbum
    psutil
    pyyaml
    sh
    xonsh
    xonsh-direnv
    xontrib-argcomplete
    xontrib-autoxsh
    xontrib-fzf-widgets
    xontrib-jump-to-dir
    xontrib-onepath
    xontrib-output-search
    xontrib-sh
  ]);
}
