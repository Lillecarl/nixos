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
    ./lpp.nix
    ./metallb.nix
    ./cert-manager.nix
    (
      { config, ... }:
      {
        coredns = {
          enable = true;
          clusterDomain = "ksb.lillecarl.com";
          clusterIP = "10.133.0.10";
        };
        local-path-provisioner.enable = true;
        metal-lb.enable = true;
        cert-manager.enable = true;
      }
    )
  ];
}
