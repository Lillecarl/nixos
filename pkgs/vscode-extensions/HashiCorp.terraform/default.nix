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
    sha256 = "7db866fa888841066811978e78c7236905f7d0ebb0335c7ed9fd553704af908d";
  };

  meta = with lib; {
    description = ''
      Syntax highlighting and autocompletion for Terraform.
    '';
    license = licenses.mit;
  };
}
