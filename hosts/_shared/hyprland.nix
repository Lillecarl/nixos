{ pkgs, lib, inputs, self, ... }:
let
  pin =
    let
      src = inputs.hyprscroller;
      pinpath = "${src}/hyprpm.toml";
      toml = builtins.fromTOML (builtins.readFile pinpath);
      pins = toml.hyprscroller.commit_pins;
      pin = lib.lists.last pins;
      landrev = lib.elemAt pin 0;
      scrollrev = lib.elemAt pin 1;
    in
    {
      inherit landrev scrollrev;
    };

  hyprscroller = pkgs.callPackage "${self}/pkgs/hyprscroller.nix" {
    inherit hyprland;
    src = pkgs.fetchFromGitHub {
      owner = "dawsers";
      repo = "hyprscroller";
      rev = pin.scrollrev;
      sha256 = "sha256-hg1kQ1fzLRbxPI5hJdtZOsT61mzKNtgVqGqSW8wYycc=";
    };
  };

  hyprland =
    let
      src = pkgs.fetchFromGitHub {
        owner = "hyprwm";
        repo = "hyprland";
        rev = pin.landrev;
        sha256 = "sha256-Urb/njWiHYUudXpmK8EKl9Z58esTIG0PxXw5LuM2r5g=";
      };

      flake = inputs.get-flake src;

      pkg = flake.packages.${pkgs.system}.hyprland;
    in
    pkg;
in
{
  options.programs.hyprland.plugins = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = "Hyprland plugins to install.";
  };
  config = {
    programs.hyprland = {
      enable = true;
      package = hyprland;
      plugins = [ hyprscroller ];
    };

    programs.nm-applet.enable = true;
  };
}
