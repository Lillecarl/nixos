{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
let
  pname = "typos-vscode";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "tekumara";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-LzemgHVCuLkLaJyyrJhIsOOn+OnYuiJsMSxITNz6R8g=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  meta = with lib; {
    description = "Typo language server";
    homepage = "https://github.com/tekumara/typos-vscode";
    license = licenses.mit;
    #maintainers = with maintainers; [ ];
  };
}
