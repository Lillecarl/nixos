{ buildPgrxExtension
, fetchFromGitHub
, pkg-config
, postgresql
}:
let
  src = fetchFromGitHub {
    owner = "kaspermarstal";
    repo = "plprql";
    rev = "v1.0.0";
    sha256 = "sha256-2huSmh1PPJt9wwM1ZmsKjh6XC/bIoJy1fFn55x4ukds=";
  };
in
buildPgrxExtension {
  inherit postgresql;

  pname = "plprql";
  buildAndTestSubdir = "plprql";
  version = "1.0.0";

  inherit src;

  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = { };
  };

  postPatch = ''
    substituteInPlace ./plprql/plprql.control --subst-var-by CARGO_VERSION 1.0.0
  '';
}
