{ lib, pkgs, ... }: {
  imports = [
    ./remote_state.nix
    ./required_providers.nix
    ./state.nix
    ./lib.nix
    ./helm.nix
    ./kv.nix
  ];
}
