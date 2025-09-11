{
  kubenix,
  config,
  lib,
  pkgs,
  ...
}:
let
  namespace = "local-path-provisioner";
  repo = pkgs.fetchFromGitHub {
    owner = "rancher";
    repo = "local-path-provisioner";
    rev = "v0.0.30";
    sha256 = "sha256-FsKx5FO9u1+WNqjPjfl4O7uxPC+F44P++Am6r4Y6OPw=";
  };
in
{
  kubernetes.api.resources.namespaces.${namespace} = { };
  kubernetes.helm.releases.local-path-provisioner = {
    namespace = namespace;

    chart = pkgs.stdenvNoCC.mkDerivation {
      name = "local-path-provisioner";
      phases = [ "installPhase" ];
      installPhase = # bash
        ''
          mkdir $out
          cp -r ${repo}/deploy/chart/local-path-provisioner/* $out
        '';
    };

    values = {
      storageClass = {
        create = true;
        defaultClass = true;
        provisionerName = "rancher.io/local-path";
        defaultVolumeType = "local";
      };
      nodePathMap = [
        {
          node = "DEFAULT_PATH_FOR_NON_LISTED_NODES";
          paths = [ "/var/lib/rancher/k3s/storage" ];
        }
      ];
      configmap = {
        setup = ''
          #!/bin/sh
          set -eu
          mkdir -m 0777 -p "$VOL_DIR"
          chmod 700 "$VOL_DIR/.."
        '';
      };
    };
  };
}
