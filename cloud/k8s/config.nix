{ lib, pkgs, ... }:
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
  };
}
