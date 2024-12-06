{
  buildPgrxExtension,
  fetchFromGitHub,
  pkg-config,
  postgresql,
}:
let
  name = "pg_graphql";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "supabase";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-Q6XfcTKVOjo5pGy8QACc4QCHolKxEGU8e0TTC6Zg8go=";
  };
in
buildPgrxExtension {
  inherit postgresql src version;

  pname = name;
  #buildAndTestSubdir = "plprql";

  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = { };
  };

  postPatch = # bash
    ''
      substituteInPlace ./${name}.control --subst-var-by CARGO_VERSION ${version}
    '';

  meta = {
    inherit (postgresql.meta) platforms;
  };
}
