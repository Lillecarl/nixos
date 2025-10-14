{
  pkgs ? import <nixpkgs> { },
}:
let
  easykubenix =
    let
      path = /home/lillecarl/Code/easykubenix;
    in
    if builtins.pathExists path then
      import path
    else
      import (
        builtins.fetchTree {
          type = "github";
          owner = "lillecarl";
          repo = "easykubenix";
        }
      );
in
easykubenix {
  inherit pkgs;
  modules = [
    ./coredns.nix
    (
      { config, ... }:
      {
        coredns = {
          enable = true;
          clusterDomain = "ksb.lillecarl.com";
          clusterIP = "10.133.0.10";
        };
      }
    )
  ];
}
