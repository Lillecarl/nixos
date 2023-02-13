{ python3
, python3Packages
, symlinkJoin
}:

symlinkJoin {
  name = "xonsh-joined";
  # recurse all listed dependencies
  paths = with python3Packages; (python3.pkgs.requiredPythonModules [
    xonsh-direnv
    xonsh-autoxsh
    xontrib-argcomplete
    xontrib-output-search
    xontrib-fzf-widgets
    xontrib-sh
    xontrib-jump-to-dir
    lazyasd
    pyyaml
    psutil
    jinja2
  ]);
}
