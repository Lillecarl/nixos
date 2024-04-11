{ pkgs
, inputs
, config
, ...
}:
{
  programs.carapace = {
    enable = true;

    package = pkgs.callPackage "${pkgs.path}/pkgs/shells/carapace" {
      buildGoModule = args: pkgs.buildGoModule (args // {
        version = inputs.carapace.shortRev;
        src = inputs.carapace;
        vendorHash = "sha256-HWczvkItE9SVGGQkddnb7/PBkTWrDAdKHjMOztlYV9M=";
      });
    };

    enableFishIntegration = true;

    enabledCompleters = [
      "vault"
    ];
  };
  home.packages = [
    config.programs.carapace.package
  ];
}
