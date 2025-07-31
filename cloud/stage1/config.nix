{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Thanks https://github.com/farcaller/nix-kube-generators/blob/master/lib/default.nix
  downloadHelmChart =
    {
      repo,
      chart,
      version,
      chartHash ? pkgs.lib.fakeHash,
    }:
    let
      pullCommand =
        if lib.hasPrefix "oci://" repo then
          ''
            ${pkgs.kubernetes-helm}/bin/helm pull \
              "${repo}" \
              --version "${version}" \
              -d $OUT_DIR \
              --untar
          ''
        else
          ''
            ${pkgs.kubernetes-helm}/bin/helm pull \
              --repo "${repo}" \
              --version "${version}" \
              "${chart}" \
              -d $OUT_DIR \
              --untar
          '';
    in
    pkgs.stdenv.mkDerivation {
      name = "helmchart-${chart}-${version}";
      nativeBuildInputs = [ pkgs.cacert ];

      phases = [ "installPhase" ];
      installPhase = ''
        export HELM_CACHE_HOME="$TMP/.nix-helm-build-cache"
        OUT_DIR="$TMP/temp-chart-output"
        mkdir -p "$OUT_DIR"
        mkdir -p "$HELM_CACHE_HOME"
        mkdir -p "$out"
        ${pullCommand}
        mv $OUT_DIR/${chart} "$out/${chart}"
      '';

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = chartHash;
    };

  dragonfly-chart = downloadHelmChart {
    repo = "oci://ghcr.io/dragonflydb/dragonfly/helm/dragonfly";
    chart = "dragonfly";
    version = "v1.26.0";
    chartHash = "sha256-aXIYu1HOVzpgqAodxcy/nkficJDCcvzrXKKtkKMJlpY=";
  };
  cnpg-chart = downloadHelmChart {
    repo = "https://cloudnative-pg.io/charts";
    chart = "cloudnative-pg";
    version = "0.23.0";
    chartHash = "sha256-UPuNKFWmZP8cZE1xOllkoEM7gOtc+TwQm6MIDKA05Ug=";
  };
  cilium-chart = downloadHelmChart {
    repo = "https://helm.cilium.io";
    chart = "cilium";
    version = "1.16.5";
    chartHash = "sha256-vDlQDb0cGSlphD8zA22TlKm4P4cVW68SrCrJLUFZR9U=";
  };
  external_dns-chart = downloadHelmChart {
    repo = "oci://registry-1.docker.io/bitnamicharts/external-dns";
    chart = "external-dns";
    version = "8.7.1";
    chartHash = "sha256-ZTUgh18fh0V27GyB+qiSUlQawKHWhu3d2qGVVHNOMA8=";
  };
  cert_manager-chart = downloadHelmChart {
    repo = "https://charts.jetstack.io";
    chart = "cert-manager";
    version = "1.16.2";
    chartHash = "sha256-rOkG5UVFx/s07Yyk7+irAPHQZCrV9alnSt9LhdjwCuA=";
  };
  cert_manager_csi_driver-chart = downloadHelmChart {
    repo = "https://charts.jetstack.io";
    chart = "cert-manager-csi-driver";
    version = "0.10.1";
    chartHash = "sha256-uet2RM2SC2xNUXBOfUxe3ZBt+KNmDdWkOUNH9QtY2SA=";
  };
  trust_manager-chart = downloadHelmChart {
    repo = "https://charts.jetstack.io";
    chart = "trust-manager";
    version = "0.14.0";
    chartHash = "sha256-GEMNhJjaTz9fqUrJ972gDGXCxLOK+Ve4taCZowo9W8Q=";
  };
  chaoskube-chart = downloadHelmChart {
    repo = "https://linki.github.io/chaoskube";
    chart = "chaoskube";
    version = "0.4.0";
    chartHash = "sha256-UosQPXXTWm1Tp8jnHvcJUcugirS/DwXxVeR6PO0++UU=";
  };
  coredns-chart = downloadHelmChart {
    repo = "https://coredns.github.io/helm";
    chart = "coredns";
    version = "1.37.0";
    chartHash = "sha256-V1492bMu4TzGxk02R39nlZjpZyVei198CI6ZDzk72t0=";
  };
  external_secrets-chart = downloadHelmChart {
    repo = "https://charts.external-secrets.io";
    chart = "external-secrets";
    version = "0.12.1";
    chartHash = "sha256-gU5QzxOzYqIBLbNZIdj06+Yl6im2Seh+n9OBH4/ddkc=";
  };
  hcloud_ccm-chart = downloadHelmChart {
    repo = "https://charts.hetzner.cloud";
    chart = "hcloud-cloud-controller-manager";
    version = "1.21.0";
    chartHash = "sha256-dXPuQvMKiB0nKUXMP01SRIDsHmOxQlvHG0vvoTYGE9c=";
  };
  hcloud_csi-chart = downloadHelmChart {
    repo = "https://charts.hetzner.cloud";
    chart = "hcloud-csi";
    version = "2.11.0";
    chartHash = "sha256-9K+Axt4GygTds2n3hNonxtHh8GvG9x8el+BTyVxVckA=";
  };
  keycloak-chart = downloadHelmChart {
    repo = "oci://registry-1.docker.io/bitnamicharts/keycloak";
    chart = "keycloak";
    version = "24.3.2";
    chartHash = "sha256-XtYF6e99mXIYq3Hinkk9va6Elc690Ki0cfWzkXoaLrE=";
  };
  ingress_nginx-chart = downloadHelmChart {
    repo = "https://kubernetes.github.io/ingress-nginx";
    chart = "ingress-nginx";
    version = "4.12.0";
    chartHash = "sha256-BwGi7t+Jdtstzy01ggJNxyAp13wTcfkEumAjdsCLbPk=";
  };
  docker_registry_ui-chart = downloadHelmChart {
    repo = "https://helm.joxit.dev";
    chart = "docker-registry-ui";
    version = "1.1.3";
    chartHash = "sha256-X4w5c0W7+O88LUzs0aJETL2VDoeU1A12FlKXU3wNZH0=";
  };
  reloader-chart = downloadHelmChart {
    repo = "https://stakater.github.io/stakater-charts";
    chart = "reloader";
    version = "1.2.0";
    chartHash = "sha256-7a6+2NfTeIgmnGfvU6haUXU94rO5RGKNDNmd3KX2E/c=";
  };
  vault-chart = downloadHelmChart {
    repo = "https://helm.releases.hashicorp.com";
    chart = "vault";
    version = "0.29.1";
    chartHash = "sha256-dilwGm8Jr1wANpLucSBtjkdu1qY4SZ/kPbc2lKDp9N0=";
  };
  oauth2_proxy-chart = downloadHelmChart {
    repo = "https://oauth2-proxy.github.io/manifests";
    chart = "oauth2-proxy";
    version = "7.9.0";
    chartHash = "sha256-wN3TaUme6vFtYlQcl3j82rirCR4JPCeUN4IZZKYE1j4=";
  };
  roundcube-chart = downloadHelmChart {
    repo = "https://helm-charts.mlohr.com";
    chart = "roundcube";
    version = "1.16.0";
    chartHash = "sha256-oYnbzc0Ul4h48+u5KXQDAgWX86sMg/TooGsHh2XAP6c=";
  };
  mariadb_operator-chart = downloadHelmChart {
    repo = "https://helm.mariadb.com/mariadb-operator";
    chart = "mariadb-operator";
    version = "0.36.0";
    chartHash = "sha256-Sii3ZbJ5jlnuzNfjYygKHvl1Or1zbxhywidHNknhu/E=";
  };
  nextcloud-chart = downloadHelmChart {
    repo = "https://nextcloud.github.io/helm";
    chart = "nextcloud";
    version = "6.5.2";
    chartHash = "sha256-htEwsHWMoUgskfLCjA8DX4M9FRtdewTxlhfwpU/9XuA=";
  };
  grafana-chart = downloadHelmChart {
    repo = "https://grafana.github.io/helm-charts";
    chart = "grafana";
    version = "8.8.2";
    chartHash = "sha256-9bDAsBtUF7LwoqsfW45Gnu+yzQqrc6yskRzNcHavrYo=";
  };
  victoria-metrics-operator-chart = downloadHelmChart {
    repo = "https://victoriametrics.github.io/helm-charts/";
    chart = "victoria-metrics-operator";
    version = "0.40.4";
    chartHash = "sha256-9XGt+xdBzE3H+PpLPxNG7xWxEqk1r3Vz4BxeCCSaYtI=";
  };
  victoria-metrics-k8s-stack-chart = downloadHelmChart {
    repo = "https://victoriametrics.github.io/helm-charts/";
    chart = "victoria-metrics-k8s-stack";
    version = "0.33.3";
    chartHash = "sha256-+j5y66e95oysbyvdt/Oj0zH1+YNjcy1maLc/JFKBQ4U=";
  };
  charts = pkgs.symlinkJoin {
    name = "helm-chart-collection";
    paths = [
      cert_manager-chart
      cert_manager_csi_driver-chart
      chaoskube-chart
      cilium-chart
      cnpg-chart
      coredns-chart
      docker_registry_ui-chart
      dragonfly-chart
      external_dns-chart
      external_secrets-chart
      hcloud_ccm-chart
      hcloud_csi-chart
      ingress_nginx-chart
      keycloak-chart
      reloader-chart
      trust_manager-chart
      vault-chart
      oauth2_proxy-chart
      local_path_provisioner-chart
      roundcube-chart
      mariadb_operator-chart
      nextcloud-chart
      grafana-chart
      victoria-metrics-operator-chart
      victoria-metrics-k8s-stack-chart
    ];
  };

  local_path_provisioner-repo = pkgs.fetchFromGitHub {
    owner = "rancher";
    repo = "local-path-provisioner";
    rev = "v0.0.30";
    sha256 = "sha256-FsKx5FO9u1+WNqjPjfl4O7uxPC+F44P++Am6r4Y6OPw=";
  };
  local_path_provisioner-chart = pkgs.stdenv.mkDerivation {
    name = "helmchart-local-path-provisioner-0.0.30";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/local-path-provisioner
      cp -r ${local_path_provisioner-repo}/deploy/chart/local-path-provisioner/* $out/local-path-provisioner/
    '';
  };

  olm-version = "0.30.0";
  prometheus-version = "0.79.2";
  cnpg-version = "1.25.0";
  cert_manager-version = "1.16.2";
  nginx-version = "1.12.0-beta.0";
  rook-version = "1.16.0";
  valkey-version = "0.0.42";
  dragonfly-operator-version = "1.1.8";
  cilium-version = "1.16.5";
  cnpg-chart-version = "cloudnative-pg-v0.23.0";

  dragonfly-operator-repo = pkgs.fetchFromGitHub {
    owner = "dragonflydb";
    repo = "dragonfly-operator";
    rev = "v${dragonfly-operator-version}";
    sha256 = "sha256-xCCqPCKPpRDJdHhjJ0HzU/Ha6jxXB+7qyS64cUVyXPs=";
  };
  cilium-repo = pkgs.fetchFromGitHub {
    owner = "cilium";
    repo = "cilium";
    rev = "v${cilium-version}";
    sha256 = "sha256-LNO22MFB6b6clfBXsAyU+PzKiP8I/AcERcx2gIDPZ24=";
  };
  cnpg-chart-repo = pkgs.fetchFromGitHub {
    owner = "cloudnative-pg";
    repo = "charts";
    rev = cnpg-chart-version;
    sha256 = "sha256-xmvWf5H+nvFjhIPKnyDvAjJyeRLZYNlYa8s/spVqOLE=";
  };
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
        url = "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v${olm-version}/crds.yaml";
        sha256 = "sha256-HFR5j7szJW2KU/YVzUQjagLDxZvSQ2KpmKL+nYHO9Pg=";
      }
    );
    olm-olm = toString (
      pkgs.fetchurl {
        url = "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v${olm-version}/olm.yaml";
        sha256 = "sha256-CXCTagaGZ1c+QCEEPqcTv9UwojadYscUOVQwpVYdQb8=";
      }
    );
    nginx-bundle = toString (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v${nginx-version}/deploy/static/provider/cloud/deploy.yaml";
        sha256 = "sha256-Bm4k2hezCmSBJhsAMqm83lH06A3gqIyaKB1BA1SxdGE=";
      }
    );
    valkey-bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/hyperspike/valkey-operator/releases/download/v${valkey-version}/install.yaml";
        sha256 = "sha256-rNmQyIkZ7GVLEBhmZ/ZoXeV/ynDB74Qulx7qFjtjuKM=";
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
    cacert-bundle = toString (
      pkgs.cacert.override {
        extraCertificateFiles = [
          (pkgs.writeText "cabundle" (
            builtins.readFile "${builtins.getEnv "FLAKE"}/resources/letsencrypt-stg-root-x1.pem"
          ))
        ];
      }
    );
    dragonfly-chart-home = "${dragonfly-operator-repo}/charts";
    cilium-chart-home = "${cilium-repo}/install/kubernetes";
    cnpg-chart-home = "${cnpg-chart-repo}/charts";
    cnpg-chart-home2 = "${cnpg-chart}";
    charts = toString charts;
    helm-path = lib.getExe pkgs.kubernetes-helm;
  };
}
