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
        vendorHash = "sha256-pcvxIPyJwptYx5964NzR9LUJTld2JVA0zaSjGH5sz4E=";
      });
    };

    enableFishIntegration = true;
  };
}
