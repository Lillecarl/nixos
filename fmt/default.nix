# treefmt.nix
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs.fish_indent.enable = true;
  programs.nixfmt.enable = true;
  programs.ruff-format.enable = true;
  programs.terraform.enable = true;
  programs.yamlfmt.enable = true;
}
