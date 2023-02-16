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
      sha256 = "sha256-I2ud9d4VtgiiIT0MeoaMThgjLYtSuftFVZHVJTMlJ8s=";
    };

    meta = with lib; {
      description = ''
        Develop, deploy and debug Kubernetes applications.
      '';
      license = licenses.mit;
    };
  }
