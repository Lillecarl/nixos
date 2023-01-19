final: prev: {
  xonsh = prev.writeShellScriptBin "xonsh" ''
    export PYTHONPATH=${prev.python3.pkgs.makePythonPath [
      final.xonsh-direnv
      final.xontrib-argcomplete
      final.xontrib-output-search
      final.xontrib-fzf-widgets
      final.xontrib-sh
      final.xontrib-jump-to-dir
      final.lazyasd
      prev.xonsh
      prev.python3.pkgs.pyyaml
      prev.python3.pkgs.psutil
      prev.python3.pkgs.jinja2
    ]};

    ${prev.xonsh}/bin/xonsh $@
  '';
}
