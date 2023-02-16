{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vscode-graphviz";
      publisher = "joaompinto";
      version = "0.0.6";
      sha256 = "sha256-fMy4fljclHhYz+SF69A54E/b482ad/wakpUkivL75Z8=";
    };

    meta = with lib; {
      description = ''
        This extension provides GraphViz (dot) language support for Visual Studio Code.
      '';
      license = licenses.mit;
    };
  }
