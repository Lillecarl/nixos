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
    (lib.hiPrio xonsh-wrapper)
    xonsh
    xonsh-direnv
    xontrib-autoxsh
    xontrib-argcomplete
    xontrib-output-search
    xontrib-fzf-widgets
    xontrib-sh
    xontrib-jump-to-dir
    xontrib-onepath
    lazyasd
    pyyaml
    psutil
    jinja2
    plumbum
    PyGithub
    sh
    kubernetes
  ]);
}
