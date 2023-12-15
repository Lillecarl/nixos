{ pkgs
, inputs
, ...
}:
{
  programs.carapace = {
    enable = true;

    package = pkgs.callPackage "${pkgs.path}/pkgs/shells/carapace" {
      buildGoModule = args: pkgs.buildGoModule (args // {
        version = inputs.carapace.shortRev;
        src = inputs.carapace;
        vendorHash = "sha256-QYNNKbGWg8jc+ojOE4usIJOs4MFYnOMbxLHzmkxRJsI=";
      });
    };

    enableFishIntegration = true;
  };
}
