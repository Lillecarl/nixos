# treefmt.nix
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "*.fmt"
    "*.age"
    "*.pem"
    "*.conf"
    "*.jpg"
    "*.txt"
    "*.md"
    ".gitignore"
  ];

  programs.fish_indent.enable = true;
  programs.nixfmt.enable = true;
  programs.ruff-format.enable = true;
  programs.stylua.enable = true;
  programs.taplo.enable = true;
  programs.terraform.enable = true;
  programs.toml-sort.enable = true;
  programs.hclfmt.enable = true;
  programs.jsonfmt.enable = true;
  programs.yamlfmt = {
    enable = true;
    settings = {
      trim_trailing_whitespace = true;
      scan_folded_as_literal = true;
      indentless_arrays = true; # k8s does this
      eof_newline = true;
    };
  };
}
