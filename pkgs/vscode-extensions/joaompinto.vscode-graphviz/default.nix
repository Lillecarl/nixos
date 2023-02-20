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
    sha256 = "7cccb87e58dc947858cfe485ebd039e04fdbe3cd9a77fc1a9295248af2fbe59f";
  };

  meta = with lib; {
    description = ''
      This extension provides GraphViz (dot) language support for Visual Studio Code.
    '';
    license = licenses.mit;
  };
}
