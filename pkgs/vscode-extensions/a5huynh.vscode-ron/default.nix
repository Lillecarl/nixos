{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-ron";
    publisher = "a5huynh";
    version = "0.10.0";
    sha256 = "0e6c9813b447397fd1adb20f602abfc74974f354b39b204077bc8749438f90e0";
  };

  meta = with lib; {
    description = ''
      Rusty Object Notation (RON) syntax package.
    '';
    license = licenses.mit;
  };
}
