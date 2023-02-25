{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  versioninfo = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-yaml";
    publisher = "redhat";
    version = versioninfo.version;
    sha256 = versioninfo.sha256;
  };

  meta = with lib; {
    description = ''
      YAML Language Support by Red Hat, with built-in Kubernetes syntax support
    '';
    license = licenses.mit;
  };
}
