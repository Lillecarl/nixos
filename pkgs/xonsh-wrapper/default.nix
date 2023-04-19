{ writeShellScriptBin
, xonsh-joined
, xonsh
,
}:
writeShellScriptBin "xonsh" ''
  export PYTHONPATH="${xonsh-joined}/lib/python3.10/site-packages:$PYTHONPATH"
  export PATH="$PATH:${xonsh-joined}/bin"

  exec ${xonsh}/bin/..xonsh-wrapped-wrapped $@
''
