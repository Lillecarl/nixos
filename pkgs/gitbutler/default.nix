{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, wrapGAppsHook
, atk
, bzip2
, cairo
, gdk-pixbuf
, glib
, gtk3
, libgit2
, libsoup
, openssl
, pango
, sqlite
, webkitgtk
, zlib
, zstd
, stdenv
, darwin
}:
rustPlatform.buildRustPackage rec {
  pname = "gitbutler";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    rev = "v${version}";
    hash = "sha256-a/AxqBp/uzvecKo9RrbUL7sX2Y1zImGjEERtRwDrCYE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tauri-plugin-context-menu-0.5.0" = "sha256-ftvGrJoQ4YHVYyrCBiiAQCQngM5Em15VRllqSgHHjxQ=";
      "tauri-plugin-single-instance-0.0.0" = "sha256-ATw3dbvG3IsLaLBg5wGk7hVRqipwL4xPGKdtD9a5VIw=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    atk
    bzip2
    cairo
    gdk-pixbuf
    glib
    gtk3
    libgit2
    libsoup
    openssl
    pango
    sqlite
    webkitgtk
    zlib
    zstd
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.Security
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = with lib; {
    description = "The GitButler version control client, backed by Git, powered by Tauri/Rust/Svelte";
    homepage = "https://github.com/gitbutlerapp/gitbutler";
    #license = licenses.unfree;
    maintainers = with maintainers; [ ];
    mainProgram = "gitbutler";
  };
}
