{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  versioninfo = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-pylance";
    publisher = "ms-python";
    version = versioninfo.version;
    sha256 = versioninfo.sha256;
  };

  meta = with lib; {
    description = ''
      A performant, feature-rich language server for Python in VS Code.
    '';
    license = licenses.mit;
  };
}
