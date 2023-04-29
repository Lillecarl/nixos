{ writeShellScriptBin
, keychain
}:
writeShellScriptBin "keychain" ''
  # Only create keychain dir if XDG specification is set
  if ! [[ -z $XDG_RUNTIME_DIR ]]; then
    mkdir -p "$XDG_RUNTIME_DIR"/keychain
    exec ${keychain}/bin/keychain --dir "$XDG_RUNTIME_DIR"/keychain $@
  fi

  # Execute normal keychain just as is
  exec ${keychain}/bin/keychain $@
''
