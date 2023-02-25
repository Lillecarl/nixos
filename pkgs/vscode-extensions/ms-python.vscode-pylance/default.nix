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
    version = "2023.2.43";
    sha256 = "789672bea483cdf6e8f821736878d157a2693731a4871130c2575efef378740c";
  };

  meta = with lib; {
    description = ''
      A performant, feature-rich language server for Python in VS Code.
    '';
    license = licenses.mit;
  };
}
