{ config
, pkgs
, lib
, inputs
, system
, ...
}:
{
  environment.systemPackages = [
    # Add disko command
    inputs.disko.packages.${pkgs.system}.default
    # Add useful CLI tools
    inputs.nixpkgs.ripgrep
    inputs.nixpkgs.gitui
    inputs.nixpkgs.htop
  ];

  nix = {
    # Enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
    # Add flake inputs to flake registry
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  system.stateVersion = "23.11";
}
