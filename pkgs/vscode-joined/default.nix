{ vscode
, symlinkJoin
, python3
}:

symlinkJoin {
  name = "vscode-joined";
  pname = vscode.pname;
  version = vscode.version;
  # recurse all listed dependencies
  paths = [
    vscode
    python3.pkgs.python-lsp-server
  ];
}
