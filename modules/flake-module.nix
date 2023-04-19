{ inputs
, lib
, ...
}: {
  flake = {
    nixosModules.ifupdown2 = import ./nixos/ifupdown2;
  };
}
