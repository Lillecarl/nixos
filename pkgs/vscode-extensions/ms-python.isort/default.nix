{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "isort";
      publisher = "ms-python";
      version = "2023.9.10461023";
      sha256 = "e91951dab291438d60a2efe5b4118f433a16518dcb6cddb7cc229f66df90761b";
    };

    meta = with lib; {
      description = ''
        Import Organization support for Python files using `isort`.
      '';
      license = licenses.mit;
    };
  }
