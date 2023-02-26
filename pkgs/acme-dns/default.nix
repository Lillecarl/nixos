{ lib
, buildGoModule
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
# If you don't know how to get the sha256's ahead of time, just build and check CLI output.
buildGoModule rec {
  pname = "acme-dns";
  version = versiondata.version;

  src = fetchFromGitHub versiondata;
  vendorSha256 = "sha256-q/P+cH2OihvPxPj2XWeLsTBHzQQABp0zjnof+Ys/qKo=";

  doCheck = false;

  meta = {
    description = "Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely.";
    homepage = "https://github.com/joohoi/acme-dns";
    license = lib.licenses.mit;
  };
}
