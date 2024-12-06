{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "hl";
  version = "0.29.4";

  src = fetchFromGitHub {
    owner = "pamburus";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-jnJKKfLpBq6zXA/GLoxxNzV6KB7Qfr4A+NdUpKbB3hY=";
  };

  #cargoHash = "sha256-jtBw4ahSl88L0iuCXxQgZVm1EcboWRJMNtjxLVTtzts=";
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "htp-0.4.2" = "sha256-oYLN0aCLIeTST+Ib6OgWqEgu9qyI0n5BDtIUIIThLiQ=";
      "wildflower-0.3.0" = "sha256-vv+ppiCrtEkCWab53eutfjHKrHZj+BEAprV5by8plzE=";
    };
  };

  meta = {
    description = "A fast and powerful log viewer and processor that translates JSON or logfmt logs into a pretty human-readable format. High performance and convenient features are the main goals.";
    homepage = "https://github.com/pamburus/hl";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
