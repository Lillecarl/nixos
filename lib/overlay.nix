outPath:
final: prev: {
  lib = prev.lib // import ./default.nix { inherit (prev) lib; inherit outPath; };
}
