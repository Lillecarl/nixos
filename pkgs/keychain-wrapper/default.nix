{ writeShellScriptBin
, keychain
}:
writeShellScriptBin "keychain" ''
  exec ${keychain}/bin/keychain --dir "$XDG_RUNTIME_DIR"/keychain $@
''
