{ lib, pkgs, ... }:
{
  locals = {
    prometheus_bundle = toString (
      pkgs.fetchurl {
        url = "https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.79.2/bundle.yaml";
        sha256 = "sha256-39t/bVxkgXKa7TGFIx9FJdhoFUzDz6uVjlwW7m5yiAM=";
      }
    );
  };
}
