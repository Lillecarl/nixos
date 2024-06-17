let
  repl = import ./repl.nix;
  inherit (repl) lib;

  str = "asdf";

  capitalizeFirst = str:
    let
      list = repl.lib.stringToCharacters str;
      first = lib.head list;
      upper = lib.toUpper first;
      noPrefix = lib.removePrefix first str;
      out = lib.concatStrings [ upper noPrefix ];
    in
    out;
in
capitalizeFirst "fdsa"
