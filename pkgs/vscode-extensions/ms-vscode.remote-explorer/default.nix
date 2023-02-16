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
      sha256 = "sha256-7bxIw9rYJXd7z3GMnyp8Kk5kOT/nJHDi6/NbX/PJmmc=";
    };

    meta = with lib; {
      description = ''
        Edit SSH configuration files.
      '';
      license = licenses.mit;
    };
  }
