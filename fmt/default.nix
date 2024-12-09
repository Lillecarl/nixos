# treefmt.nix
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.fish_indent.enable = true;
  programs.ruff-format.enable = true;
  programs.terraform.enable = true;
}
