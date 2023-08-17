{ python3
, symlinkJoin
, xonsh
, xonsh-wrapper
, lib
,
}:
symlinkJoin {
  name = "xonsh-joined";
  # recurse all listed dependencies
  paths = with python3.pkgs; (python3.pkgs.requiredPythonModules [
    (lib.hiPrio xonsh-wrapper)
    boto3
    PyGithub
    coconut
    from_ssv
    jinja2
    kubernetes
    lazyasd
    munch
    plumbum
    psutil
    pyping
    pyyaml
    sh
    xonsh
    xonsh-direnv
    xontrib-abbrevs
    xontrib-argcomplete
    xontrib-autoxsh
    xontrib-back2dir
    xontrib-fzf-widgets
    xontrib-jump-to-dir
    xontrib-onepath
    xontrib-output-search
    xontrib-sh
  ]);
}
