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
    version = "2.25.3";
    sha256 = "4b0dbd8bfe145ca977df1de682ed9ce00dd26e2b6f3921fc75c2cf8f25e7dad0";
  };

  meta = with lib; {
    description = ''
      Syntax highlighting and autocompletion for Terraform.
    '';
    license = licenses.mit;
  };
}
