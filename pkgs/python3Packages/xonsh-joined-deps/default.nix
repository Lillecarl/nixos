{ python3
, python3Packages
, xonsh
, symlinkJoin
}:

symlinkJoin {
  name = "xonsh-joined";
  # recurse all listed dependencies
  paths = with python3Packages; (python3.pkgs.requiredPythonModules [
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
  ]);
}
