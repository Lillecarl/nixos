final: prev: {
  # write xonsh wrapper script
  xonsh-wrapped = prev.writeShellScriptBin "xonsh" ''
    export PYTHONPATH=${final.python3Packages.xonsh-joined-deps}/lib/python3.10/site-packages:$PYTHONPATH

    export XDG_CACHE_HOME=$HOME/.cache
    export XDG_BIN_HOME=$HOME/.local/bin
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_STATE_HOME=$HOME/.local/state
    
    exec ${prev.xonsh}/bin/xonsh $@
  '';
}
