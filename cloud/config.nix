{
  lib,
  pkgs,
  config,
  ...
}:
let
  olm-version = "0.30.0";
  prometheus-version = "v0.79.2";
  cnpg-version = "1.25.0";
  cert_manager-version = "1.16.2";
  nginx-version = "1.12.0-beta.0";
  rook-version = "1.16.0";
in
{
  locals.nixpaths = {
    prometheus-bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/prometheus-operator/prometheus-operator/releases/download/v${prometheus-version}/bundle.yaml";
        sha256 = "sha256-39t/bVxkgXKa7TGFIx9FJdhoFUzDz6uVjlwW7m5yiAM=";
      }
    );
    cnpg-bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v${cnpg-version}/cnpg-${cnpg-version}.yaml";
        sha256 = "sha256-VAMlYSMT93W2JKREwhfEwYUSacBD9yynPbz2r/Qz3LQ=";
      }
    );
    cert_manager-bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/cert-manager/cert-manager/releases/download/v${cert_manager-version}/cert-manager.yaml";
        sha256 = "sha256-HVHN7NRC8fX4l4Pp4BabldNyck2iA8x13XpcTlChDOY=";
      }
    );
    olm-crd = toString (
      pkgs.fetchurl {
        url = "https://github.com/operator-framework/olm/releases/download/v${olm-version}/crds.yaml";
        sha256 = "sha256-HFR5j7szJW2KU/YVzUQjagLDxZvSQ2KpmKL+nYHO9Pg=";
      }
    );
    olm-olm = toString (
      pkgs.fetchurl {
        url = "https://github.com/operator-framework/olm/releases/download/v${olm-version}/olm.yaml";
        sha256 = "sha256-CXCTagaGZ1c+QCEEPqcTv9UwojadYscUOVQwpVYdQb8=";
      }
    );
    nginx-bundle = toString (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v${nginx-version}/deploy/static/provider/cloud/deploy.yaml";
        sha256 = "sha256-Bm4k2hezCmSBJhsAMqm83lH06A3gqIyaKB1BA1SxdGE=";
      }
    );
    rook-repo = toString (
      pkgs.fetchFromGitHub {
        owner = "rook";
        repo = "rook";
        rev = "v${rook-version}";
        sha256 = "sha256-kn8h/3s/U1hHVM0n6r6RvafSGnnYuxOkJSSJPe7KEc8=";
      }
    );
    helm-path = lib.getExe pkgs.kubernetes-helm;
  };
}
