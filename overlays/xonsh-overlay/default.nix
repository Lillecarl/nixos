final: prev:
let
  # Join all xonsh dependencies into one derivation
  xonsh-joined = prev.symlinkJoin {
    name = "xonsh-joined";
    # recurse all listed dependencies
    paths = (prev.python3.pkgs.requiredPythonModules [
      final.xonsh-direnv
      final.xontrib-argcomplete
      final.xontrib-output-search
      final.xontrib-fzf-widgets
      final.xontrib-sh
      final.xontrib-jump-to-dir
      final.lazyasd
      prev.python3.pkgs.pyyaml
      prev.python3.pkgs.psutil
      prev.python3.pkgs.jinja2
    ]);
  };
in
{
  # write xonsh wrapper script
  xonsh = prev.writeShellScriptBin "xonsh" ''
    export PYTHONPATH=${xonsh-joined}/lib/python3.10/site-packages:$PYTHONPATH

    ${prev.xonsh}/bin/xonsh $@
  '';
}
