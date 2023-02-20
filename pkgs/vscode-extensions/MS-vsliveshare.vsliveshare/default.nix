{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vsliveshare";
    publisher = "MS-vsliveshare";
    version = "1.0.5831";
    sha256 = "4158b0641c5e9b4cfad812e1034cdb15d40bdd27e850a650c7a5fe026d65913d";
  };

  meta = with lib; {
    description = ''
      Real-time collaborative development from the comfort of your favorite tools.
    '';
    license = licenses.mit;
  };
}
