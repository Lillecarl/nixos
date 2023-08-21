{ pkgs }:
name: attrs: script:
let
  scriptHead = builtins.head (builtins.split "\n" script);
  finalScriptString = builtins.replaceStrings [ scriptHead ] [ "" ] script;
in
pkgs.writers.writePython3 name attrs finalScriptString
