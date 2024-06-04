{ lib
, rustPlatform
, xcb-util-cursor
, ...
}:
rustPlatform.buildRustPackage rec {
  pname = "xwayland-satellite";
  version = "git";

  src = ./.;

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
    description = "Xwayland outside your wayland";
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = lib.licenses.mspl;
    maintainers = [ ];
  };
}
