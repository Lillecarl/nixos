{ python3
, xonsh-direnv
, xonsh-autoxsh
, xontrib-argcomplete
, xontrib-output-search
, xontrib-fzf-widgets
, xontrib-sh
, xontrib-jump-to-dir
, lazyasd
, symlinkJoin
, prev
}:

symlinkJoin {
  name = "xonsh-joined";
  # recurse all listed dependencies
  paths = (python3.pkgs.requiredPythonModules [
    prev.xonsh
    xonsh-direnv
    xonsh-autoxsh
    xontrib-argcomplete
    xontrib-output-search
    xontrib-fzf-widgets
    xontrib-sh
    xontrib-jump-to-dir
    lazyasd
    python3.pkgs.pyyaml
    python3.pkgs.psutil
    python3.pkgs.jinja2
  ]);
}
