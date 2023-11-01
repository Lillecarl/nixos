{ inputs, ... }:
let
  pkgs-overlay = import ../pkgs/default.nix;
in
{
  nixpkgs.overlays = [
    inputs.hyprland.overlays.default
    inputs.nix-vscode-extensions.overlays.default
    #inputs.nixpkgs-wayland.overlay
    inputs.nur.overlay
    #inputs.waybar.overlays.default
    pkgs-overlay
  ];
}
