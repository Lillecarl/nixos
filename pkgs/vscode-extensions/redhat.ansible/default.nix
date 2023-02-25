{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  versioninfo = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "ansible";
    publisher = "redhat";
    version = versioninfo.version;
    sha256 = versioninfo.sha256;
  };

  meta = with lib; {
    description = ''
      Ansible language support.
    '';
    license = licenses.mit;
  };
}
