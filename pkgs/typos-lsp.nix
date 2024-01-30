{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "typos-vscode";
  version = "0.1.11";

  #src = fetchFromGitHub {
  #  owner = "valebes";
  #  repo = pname;
  #  rev = "v${version}";
  #  sha256 = "sha256-z+WGi1Jl+YkdAc4Nu818vi+OXg54GfAM6PbWYkgptpo=";
  #};

  src = /home/lillecarl/Code/carl/typos-vscode;

  cargoHash = "sha256-oMJUChloU/mJxZG2ujVJZ1CmZOygk7vu5MmyBctoD3s=";

  meta = with lib; {
    description = "Typo language server";
    homepage = "https://github.com/valebes/rsClock";
    license = licenses.mit;
    maintainers = with maintainers; [ valebes ];
  };
}

