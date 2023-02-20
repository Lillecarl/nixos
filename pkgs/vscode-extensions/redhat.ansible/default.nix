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
    version = "1.2.44";
    sha256 = "31f73fb13eea908ffa0040d915dd03900ba2e496b2ceb2b7cffc73705e610929";
  };

  meta = with lib; {
    description = ''
      Ansible language support.
    '';
    license = licenses.mit;
  };
}
