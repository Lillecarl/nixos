{ writeShellScriptBin
, keychain
}:
writeShellScriptBin "keychain" ''
  mkdir -p "$XDG_RUNTIME_DIR"/keychain
  exec ${keychain}/bin/keychain --dir "$XDG_RUNTIME_DIR"/keychain $@
''
