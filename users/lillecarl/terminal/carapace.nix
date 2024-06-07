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
        vendorHash = "sha256-kuZRCsaiXiuhMIOHXg0VjrtBWtg5IoGsRLzMmX0NLMk=";
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
