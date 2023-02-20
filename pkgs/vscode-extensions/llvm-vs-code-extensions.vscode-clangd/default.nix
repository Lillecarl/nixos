{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-clangd";
    publisher = "llvm-vs-code-extensions";
    version = "0.1.23";
    sha256 = "ded5fdc92b12b2820a527a6cb8e69e40dacf82127ac4887344c858a239b3b188";
  };

  meta = with lib; {
    description = ''
      C/C++ completion, navigation, and insights.
    '';
    license = licenses.mit;
  };
}
