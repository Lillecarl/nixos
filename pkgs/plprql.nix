{ buildPgrxExtension
, fetchFromGitHub
, pkg-config
, postgresql
}:
let
  name = "plprql";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "kaspermarstal";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-2huSmh1PPJt9wwM1ZmsKjh6XC/bIoJy1fFn55x4ukds=";
  };
in
buildPgrxExtension {
  inherit postgresql src version;

  pname = name;
  buildAndTestSubdir = name;


  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = { };
  };

  postPatch = ''
    substituteInPlace ./${name}/${name}.control --subst-var-by CARGO_VERSION ${version}
  '';
}
