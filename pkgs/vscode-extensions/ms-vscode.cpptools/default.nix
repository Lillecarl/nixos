{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "cpptools";
    publisher = "ms-vscode";
    version = "1.14.3";
    sha256 = "e49383bae39905f74b48e92e01d485e3223dd8419f8d6a8d33d90105e630ac9a";
  };

  meta = with lib; {
    description = ''
      C/C++ IntelliSense, debugging, and code browsing.
    '';
    license = licenses.mit;
  };
}
