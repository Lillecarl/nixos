{ writeShellScriptBin
, xonsh-joined
, xonsh
}:
writeShellScriptBin "xonsh" ''
  export PYTHONPATH="${xonsh-joined}/lib/python3.10/site-packages:$PYTHONPATH"
  export PATH="${xonsh-joined}/lib/python3.10/site-packages:$PYTHONPATH"

  exec ${xonsh}/bin/.xonsh-wrapped $@
''
