{ lib, pkgs, ... }:
{
  options.lib = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
  config = {
    lib = {
      cfbucket = name: {
        region = "us-east-1";
        bucket = "postspace-tfstate";
        key = "${name}.tfstate";
        # ignore this for r2 compatibility
        skip_credentials_validation = true;
        skip_region_validation = true;
        skip_requesting_account_id = true;
        skip_metadata_api_check = true;
        skip_s3_checksum = true;
      };
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
    };
  };
}
