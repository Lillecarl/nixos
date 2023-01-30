{ lib
, buildGoModule
, fetchFromGitHub
}:

# If you don't know how to get the sha256's ahead of time, just build and check CLI output.
buildGoModule rec {
  pname = "acme-dns";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "joohoi";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-qQwvhouqzkChWeu65epgoeMNqZyAD18T+xqEMgdMbhA=";
  };

  vendorSha256 = "sha256-q/P+cH2OihvPxPj2XWeLsTBHzQQABp0zjnof+Ys/qKo=";

  meta = {
    description = "Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely.";
    homepage = "https://github.com/joohoi/acme-dns";
    license = lib.licenses.mit;
  };
}
