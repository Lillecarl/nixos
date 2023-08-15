{ python3
, symlinkJoin
, ulauncher
,
}:
symlinkJoin {
  name = "ulauncher-joined";
  # recurse all listed dependencies
  paths = (python3.pkgs.requiredPythonModules [
    python3.pkgs.plumbum
  ]) ++ [
    ulauncher
  ];
}
