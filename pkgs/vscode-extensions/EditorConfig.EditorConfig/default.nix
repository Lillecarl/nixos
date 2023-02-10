{ lib
, vscode-utils
}:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "EditorConfig";
      publisher = "EditorConfig";
      version = "0.16.4";
      sha256 = "sha256-j+P2oprpH0rzqI0VKt0JbZG19EDE7e7+kAb3MGGCRDk=";
    };

    meta = with lib; {
      description = ''
        Xonsh language support.
      '';
      license = licenses.mit;
    };
  }
