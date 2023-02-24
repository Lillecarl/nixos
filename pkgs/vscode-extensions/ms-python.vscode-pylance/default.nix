{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-pylance";
    publisher = "ms-python";
    version = "2023.2.42";
    sha256 = "975c689a4dffb4521d830d2a6f891db9ef10e16e55604c786289387a88894849";
  };

  meta = with lib; {
    description = ''
      A performant, feature-rich language server for Python in VS Code.
    '';
    license = licenses.mit;
  };
}
