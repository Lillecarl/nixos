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
      sha256 = "sha256-6RlR2rKRQ41gou/ltBGPQzoWUY3LbN23zCKfZt+Qdhs=";
    };

    meta = with lib; {
      description = ''
        Import Organization support for Python files using `isort`.
      '';
      license = licenses.mit;
    };
  }
