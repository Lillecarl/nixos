{ config
, pkgs
, ...
}:
let
  pkgs-overlay = import ../pkgs;
in
{
  # An overlay puts our own variables in the "global namespace"
  # meaning we can add/edit packages without modifying nixpkgs
  nixpkgs.overlays = [
    pkgs-overlay
  ];

  # Add packages all users should have in their $PATH here
  home.packages = with pkgs; [
  ];

  # Make sure all users have home-manager in their profile
  programs.home-manager.enable = true;
  # This should not be changed without reading docs
  home.stateVersion = "22.05";
}
