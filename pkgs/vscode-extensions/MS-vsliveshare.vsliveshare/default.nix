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
    version = "1.0.5832";
    sha256 = "bc6bab0bef5deb73c68325c456d56aaee483b0e6c38d2869a311c3ec4b304ae9";
  };

  meta = with lib; {
    description = ''
      Real-time collaborative development from the comfort of your favorite tools.
    '';
    license = licenses.mit;
  };
}
