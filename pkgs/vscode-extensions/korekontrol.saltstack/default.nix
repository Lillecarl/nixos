{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "saltstack";
    publisher = "korekontrol";
    version = "0.0.9";
    sha256 = "8af8c90a91de13c05e69e34702f87d9ce2950d2603235c6cea95b85c4654b9a7";
  };

  meta = with lib; {
    description = ''
      SaltStack jinja template language support.
    '';
    license = licenses.mit;
  };
}
