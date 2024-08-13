{ buildPgrxExtension
, fetchFromGitHub
, pkg-config
, postgresql
, openssl
}:
let
  name = "pg_analytics";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "paradedb";
    repo = name;
    rev = "199ceece81c8fd2b83bc04991fd453b0b20d5820";
    sha256 = "sha256-rmWOPyfvKd5A/33SEvpitgp8tpbXs2XcHSDAbGwifgg=";
  };
in
buildPgrxExtension rec {
  inherit postgresql src version;

  pname = name;

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  cargoLock = {
    lockFile = ./${name}.lock;
    outputHashes = {
      "duckdb-1.0.0" = "sha256-A9/e3ERs3AqvuFTkk9wEzCotpcPWS7dTfQxsHlUx2TU=";
      "shared-0.8.6" = "sha256-bdX9GHE29ttoVWC8WusVCxGgcjFPH02PW3Zk7dDA1Yg=";
      "supabase-wrappers-0.1.18" = "sha256-dA+BsFTYXG5tpt0GDnrZjZ8RP2tPwWNJP4nF6subV4Y=";
    };
  };

  passthru = {
    shared_preload_library = "pg_analytics";
  };

  postPatch = /* bash */ ''
    ln -s ${./${name}.lock} ./Cargo.lock
    substituteInPlace ./${name}.control --subst-var-by CARGO_VERSION ${version}
  '';
}
