let
  flake = import ./default.nix;
in
flake // flake.repl
