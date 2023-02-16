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
      version = "2023.2.31";
      sha256 = "1cd881ad786319c76173bebb570325c1e57be3fd49cf8712f4fe9c144a08f6be";
    };

    meta = with lib; {
      description = ''
        A performant, feature-rich language server for Python in VS Code.
      '';
      license = licenses.mit;
    };
  }
