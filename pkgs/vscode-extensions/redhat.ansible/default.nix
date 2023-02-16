{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "ansible";
      publisher = "redhat";
      version = "1.1.34";
      sha256 = "sha256-UyAbQpe2KpoBZVk1AwfEr3BoLPwHxps284l0ZzjMQDE=";
    };

    meta = with lib; {
      description = ''
        Ansible language support.
      '';
      license = licenses.mit;
    };
  }
