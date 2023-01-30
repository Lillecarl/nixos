{ lib
, buildGoModule
, fetchFromGitHub
}:

# If you don't know how to get the sha256's ahead of time, just build and check CLI output.
buildGoModule rec {
  pname = "splunk-otel-collector";
  version = "0.68.1";

  subPackages = [ "cmd/otelcol" ];
  src = fetchFromGitHub {
    owner = "signalfx";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HhAbW9l3BXbURbTrjCQexG3gc8qUkEvFc52X8hHZImM=";
  };

  vendorSha256 = "sha256-R2IrzGcPo56JJEoDA+CFRAlba4FxpIo5e5KawOvViB0=";

  meta = {
    description = "Splunk OpenTelemetry connector";
    homepage = "https://github.com/signalfx/splunk-otel-collector";
    license = lib.licenses.asl20;
  };
}
