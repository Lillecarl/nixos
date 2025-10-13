let
  # flake-compat = import /home/lillecarl/Code/flake-compat;
  flake-compatish = import (builtins.fetchGit {
    url = "https://github.com/lillecarl/flake-compatish.git";
    ref = "main";
  });
  flake = flake-compatish ./.;
in
flake.outputs // { inherit (flake) impure; }
