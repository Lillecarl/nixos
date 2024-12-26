{
  lib,
  pkgs,
  config,
  ...
}:
let
  operator-lifecycle-manager-version = "0.30.0";
in
{
  locals = {
    prometheus_bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.79.2/bundle.yaml";
        sha256 = "sha256-39t/bVxkgXKa7TGFIx9FJdhoFUzDz6uVjlwW7m5yiAM=";
      }
    );
    cnpg_bundle = toString (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-1.25.0-rc1.yaml";
        sha256 = "sha256-j63Zu8K3on4+MvYohiw99iaXBcH+LNG8qJ3qC/eEyUI=";
      }
    );
    cert-manager_bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml";
        sha256 = "sha256-HVHN7NRC8fX4l4Pp4BabldNyck2iA8x13XpcTlChDOY=";
      }
    );
    operator-lifecycle-manager_crd = toString (
      pkgs.fetchurl {
        url = "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v${operator-lifecycle-manager-version}/crds.yaml";
        sha256 = "sha256-HFR5j7szJW2KU/YVzUQjagLDxZvSQ2KpmKL+nYHO9Pg=";
      }
    );
    operator-lifecycle-manager_olm = toString (
      pkgs.fetchurl {
        url = "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v${operator-lifecycle-manager-version}/olm.yaml";
        sha256 = "sha256-CXCTagaGZ1c+QCEEPqcTv9UwojadYscUOVQwpVYdQb8=";
      }
    );
    nginx-bundle = toString (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml";
        sha256 = "sha256-Bm4k2hezCmSBJhsAMqm83lH06A3gqIyaKB1BA1SxdGE=";
      }
    );
    helm_path = lib.getExe pkgs.kubernetes-helm;
  };
  output = builtins.mapAttrs (name: value: { inherit value; }) config.locals;
}
