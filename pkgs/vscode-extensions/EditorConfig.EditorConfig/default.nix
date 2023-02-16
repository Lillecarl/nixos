{ lib
, vscode-utils
}:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "EditorConfig";
      publisher = "EditorConfig";
      version = "0.16.4";
      sha256 = "8fe3f6a29ae91f4af3a88d152add096d91b5f440c4edeefe9006f73061824439";
    };

    meta = with lib; {
      description = ''
        Xonsh language support.
      '';
      license = licenses.mit;
    };
  }
