{ lib
, buildGoModule
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
# If you don't know how to get the sha256's ahead of time, just build and check CLI output.
buildGoModule rec {
  pname = "splunk-otel-collector";
  version = versiondata.version;

  subPackages = [ "cmd/otelcol" ];
  src = fetchFromGitHub versiondata;
  vendorSha256 = "sha256-R2IrzGcPo56JJEoDA+CFRAlba4FxpIo5e5KawOvViB0=";

  meta = {
    description = "Splunk OpenTelemetry connector";
    homepage = "https://github.com/signalfx/splunk-otel-collector";
    license = lib.licenses.asl20;
  };
}
