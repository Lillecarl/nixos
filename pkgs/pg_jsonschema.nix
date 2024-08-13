{ buildPgrxExtension
, fetchFromGitHub
, pkg-config
, postgresql
}:
let
  name = "pg_jsonschema";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "supabase";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-YdKpOEiDIz60xE7C+EzpYjBcH0HabnDbtZl23CYls6g=";
  };
in
buildPgrxExtension {
  inherit postgresql src version;

  pname = name;

  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = { };
  };

  postPatch = /* bash */ ''
    substituteInPlace ./${name}.control --subst-var-by CARGO_VERSION ${version}
  '';

  meta = {
    platforms = postgresql.meta.platforms;
  };
}
