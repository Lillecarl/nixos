let
  flake = builtins.getFlake (builtins.getEnv "FLAKE");
in
flake // flake.repl
