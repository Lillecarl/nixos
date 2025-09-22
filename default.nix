let
  # flake-compat = import /home/lillecarl/Code/flake-compat;
  flake-compat = import (builtins.fetchGit {
    url = "https://github.com/lillecarl/flake-compatish.git";
    ref = "main";
  });
  flake = flake-compat ./.;
in
flake.outputs // { inherit (flake) impure; }
