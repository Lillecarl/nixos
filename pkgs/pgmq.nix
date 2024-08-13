{ stdenv
, fetchFromGitHub
, autoPatchelfHook
, postgresql
}:
let
  name = "pgmq";
  version = "1.4.0";
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchFromGitHub {
    owner = "tembo-io";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-k7iKp2CZY3M8POUqIOIbKxrofoOfn2FxfVW01KYojPA=";
  };

  postUnpack = ''
    sourceRoot=$sourceRoot/pgmq-extension
  '';

  makeFlags = [
    # Use PGXS
    "USE_PGXS=1"
    # PGXS only supports installing to postgresql prefix so we need to redirect this
    "DESTDIR=${placeholder "out"}"
  ];

  postInstall = ''
    # Move the redirected to proper directory.
    # There appear to be no references to the install directories
    # so changing them does not cause issues.
    mv "$out/nix/store"/*/* "$out"
    rmdir "$out/nix/store"/* "$out/nix/store" "$out/nix"
  '';

  propagatedBuildInputs = [
    postgresql
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  meta = {
    platforms = postgresql.meta.platforms;
  };
}
