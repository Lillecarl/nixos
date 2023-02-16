{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "terraform";
      publisher = "HashiCorp";
      version = "2.25.2";
      sha256 = "sha256-fbhm+oiIQQZoEZeOeMcjaQX30OuwM1x+2f1VNwSvkI0=";
    };

    meta = with lib; {
      description = ''
        Syntax highlighting and autocompletion for Terraform.
      '';
      license = licenses.mit;
    };
  }
