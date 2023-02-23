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
    version = "2023.2.41";
    sha256 = "caefcbc65fdd4338236723cf34a71a44d9dc8c0ddde969bf1e1ae0fdefa65ab1";
  };

  meta = with lib; {
    description = ''
      A performant, feature-rich language server for Python in VS Code.
    '';
    license = licenses.mit;
  };
}
