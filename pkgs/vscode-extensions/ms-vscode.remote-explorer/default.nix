{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "remote-explorer";
      publisher = "ms-vscode";
      version = "0.3.2023021509";
      sha256 = "edbc48c3dad825777bcf718c9f2a7c2a4e64393fe72470e2ebf35b5ff3c99a67";
    };

    meta = with lib; {
      description = ''
        Edit SSH configuration files.
      '';
      license = licenses.mit;
    };
  }
