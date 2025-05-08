let
  # Our own patched flake-compat that evaluates impurely from disk
  flake-compat = import ./flake-compat.nix;
  flake = flake-compat { src = (builtins.toString ./.); };
in
  flake.outputs
