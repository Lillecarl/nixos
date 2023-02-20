{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-yaml";
    publisher = "redhat";
    version = "1.11.10112022";
    sha256 = "fd90f72ce7fa779749256ede199824adfe218f5097649348d2ed3a0679b2a344";
  };

  meta = with lib; {
    description = ''
      YAML Language Support by Red Hat, with built-in Kubernetes syntax support
    '';
    license = licenses.mit;
  };
}
