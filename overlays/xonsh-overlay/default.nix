final: prev:
let
in
rec {
  # Join all xonsh dependencies into one derivation
#  xonsh-joined-deps = prev.symlinkJoin {
#    name = "xonsh-joined";
#    # recurse all listed dependencies
#    paths = (prev.python3.pkgs.requiredPythonModules [
#      final.xonsh-direnv
#      final.xontrib-argcomplete
#      final.xontrib-output-search
#      final.xontrib-fzf-widgets
#      final.xontrib-sh
#      final.xontrib-jump-to-dir
#      final.lazyasd
#      prev.python3.pkgs.pyyaml
#      prev.python3.pkgs.psutil
#      prev.python3.pkgs.jinja2
#    ]);
#  };

  # write xonsh wrapper script
  xonsh = prev.writeShellScriptBin "xonsh" ''
    export PYTHONPATH=${final.xonsh-joined-deps}/lib/python3.10/site-packages:$PYTHONPATH

    export XDG_CACHE_HOME=$HOME/.cache
    export XDG_BIN_HOME=$HOME/.local/bin
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_STATE_HOME=$HOME/.local/state
    
    exec ${prev.xonsh}/bin/xonsh $@
  '';
}
