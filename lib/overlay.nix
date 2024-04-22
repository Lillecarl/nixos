outPath:
final: prev: {
  lib = prev.lib // import ./default.nix { lib = prev.lib; inherit outPath; };
}
