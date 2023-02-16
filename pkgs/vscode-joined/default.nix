{ vscode
, symlinkJoin
}:

symlinkJoin {
  name = "vscode-joined";
  pname = vscode.pname;
  version = vscode.version;
  # recurse all listed dependencies
  paths = [
    vscode
  ];
}
