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
      sha256 = "sha256-HNiBrXhjGcdhc767VwMlweV74/1Jz4cS9P6cFEoI9r4=";
    };

    meta = with lib; {
      description = ''
        A performant, feature-rich language server for Python in VS Code.
      '';
      license = licenses.mit;
    };
  }
