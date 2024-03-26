{ pkgs
, inputs
, config
, ...
}:
{
  programs.carapace = {
    enable = false;

    package = pkgs.callPackage "${pkgs.path}/pkgs/shells/carapace" {
      buildGoModule = args: pkgs.buildGoModule (args // {
        version = inputs.carapace.shortRev;
        src = inputs.carapace;
        vendorHash = "sha256-XAdTLfMnOAcOiRYZGrom2Q+qp+epfg6Y9Jv0V0T12/8=";
      });
    };

    enableFishIntegration = true;
  };
  home.packages = [
    config.programs.carapace.package
  ];
}
