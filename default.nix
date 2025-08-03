let
  # flake-compat = import /home/lillecarl/Code/flake-compat;
  flake-compat = import (builtins.fetchGit {
    url = "https://git.lix.systems/lix-project/flake-compat.git";
    ref = "main";
  });
  flake = flake-compat {
    src = (builtins.toString ./.);
    copySourceTreeToStore = false;
  };
in
flake.outputs
