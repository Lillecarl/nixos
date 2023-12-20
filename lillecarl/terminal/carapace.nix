{ pkgs
, inputs
, ...
}:
{
  programs.carapace = {
    enable = false;

    package = pkgs.callPackage "${pkgs.path}/pkgs/shells/carapace" {
      buildGoModule = args: pkgs.buildGoModule (args // {
        version = inputs.carapace.shortRev;
        src = inputs.carapace;
        vendorHash = "sha256-3LTdGA3yb9uzwrHWvxXoDbijiafyIqQYJhljEgUmLcI=";
      });
    };

    enableFishIntegration = true;
  };
}
