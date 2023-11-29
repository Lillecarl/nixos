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
        vendorHash = "sha256-4QMcA06IAlBWUm4ft0x1lkYfMxgFCnPI59/iVFCFGyQ=";
      });
    };

    enableFishIntegration = true;
  };
}
