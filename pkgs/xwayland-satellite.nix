{ lib
, fetchFromGitHub
, rustPlatform
, xcb-util-cursor
, ...
}:
rustPlatform.buildRustPackage rec {
  pname = "xwayland-satellite";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    rev = "v${version}";
    sha256 = "sha256-0nvFpHzkho7ATwvceDNdlk3CULVRP4VgKJjEO/7SCi4=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook # Find libclang.so
  ];

  buildInputs = [
    xcb-util-cursor
  ];

  # Tests are failing in Nix builds
  doCheck = false;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  meta = {
    mainProgram = pname;
    description = "Xwayland outside your wayland";
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = lib.licenses.mspl;
    maintainers = [ ];
  };
}
