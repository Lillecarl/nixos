{
  inputs = {
    # nixos branch, calling it nixpkgs because that's the default everyone uses.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    nix-community-lib.url = "github:nix-community/nixpkgs.lib";
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    waybar = {
      url = "github:Alexays/Waybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nix-community-lib";
    };
    # Use Nix as Terraform
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # Wayland packages for NixOS
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-eval-jobs.follows = "nix-eval-jobs";
      inputs.lib-aggregate.follows = "lib-aggregate";
    };
    # Support splitting flake into subflakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    # Supposed to moutn and download debug files on the fly
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manage home environment with Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Disk Partitioning with Nix
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Gives me a pre-computed programs.sqlite for command-not-found
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    # Configure non-nixos systems with Nix modules
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    mozilla-addons-to-nix = {
      url = "sourcehut:~rycee/mozilla-addons-to-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Art
    nixos-artwork = {
      url = "github:NixOS/nixos-artwork";
      flake = false;
    };
    catppuccin-alacritty = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };
    catppuccin-waybar = {
      url = "github:catppuccin/waybar";
      flake = false;
    };
    catppuccin-gitui = {
      url = "github:catppuccin/gitui";
      flake = false;
    };
    catppuccin-hyprland = {
      url = "github:catppuccin/hyprland";
      flake = false;
    };
    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
  };

  outputs =
    { self
    , flake-parts
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          flakeloc =
            if builtins.getEnv "FLAKE" == ""
            then builtins.abort "env var FLAKE is not properly configured"
            else builtins.getEnv "FLAKE";
        };
      }
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          ./hosts/wsl/flake-module.nix
          ./lillecarl/flake-module.nix
          ./modules/flake-module.nix
          ./nixos-installer/flake-module.nix
          ./nub/flake-module.nix
          ./repoenv/flake-module.nix
          ./shitbox/flake-module.nix
          ./system-manager/flake-module.nix
          ./terraform/flake-module.nix
        ];
        systems = [ "x86_64-linux" "x86_64-darwin" ];
        flake = { };
        perSystem =
          { config
          , system
          , pkgs
          , inputs'
          , ...
          }:
          let
            pkgs_overlaid = pkgs.extend (import ./pkgs);
            own_pkgs = import ./pkgs/pkgs.nix pkgs_overlaid pkgs_overlaid true;
          in
          {
            formatter = pkgs.nixpkgs-fmt;
            packages = own_pkgs;
            legacyPackages = pkgs_overlaid;
          };
      };
}
