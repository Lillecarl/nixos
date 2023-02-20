{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-kubernetes-tools";
    publisher = "ms-kubernetes-tools";
    version = "1.3.11";
    sha256 = "236b9df5de15b608a2213d0c7a868c4e18232d8b52b9fb455591d525332527cb";
  };

  meta = with lib; {
    description = ''
      Develop, deploy and debug Kubernetes applications.
    '';
    license = licenses.mit;
  };
}
