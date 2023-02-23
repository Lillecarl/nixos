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
    version = "2.25.4";
    sha256 = "a37fb80678c2eda7f36b46529427c8ef0404cd751866c8de3c8401ba48932825";
  };

  meta = with lib; {
    description = ''
      Syntax highlighting and autocompletion for Terraform.
    '';
    license = licenses.mit;
  };
}
