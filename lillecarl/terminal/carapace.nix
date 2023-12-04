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
        vendorHash = "sha256-rR0mLO8jjhTPySQ/BTegNe9kd2DudULOuYBBB/P9K1s=";
      });
    };

    enableFishIntegration = true;
  };
}
