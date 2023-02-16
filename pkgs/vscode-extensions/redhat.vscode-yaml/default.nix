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
      sha256 = "sha256-/ZD3LOf6d5dJJW7eGZgkrf4hj1CXZJNI0u06Bnmyo0Q=";
    };

    meta = with lib; {
      description = ''
        YAML Language Support by Red Hat, with built-in Kubernetes syntax support
      '';
      license = licenses.mit;
    };
  }
