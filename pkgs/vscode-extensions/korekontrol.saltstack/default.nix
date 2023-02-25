{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  versioninfo = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "saltstack";
    publisher = "korekontrol";
    version = versioninfo.version;
    sha256 = versioninfo.sha256;
  };

  meta = with lib; {
    description = ''
      SaltStack jinja template language support.
    '';
    license = licenses.mit;
  };
}
