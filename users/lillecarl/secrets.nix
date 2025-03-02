{ self, config, inputs, ... }:
{
  imports = [
    inputs.agenix.homeManagerModules.age
  ];
  config.age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/agenix"
    ];
    secrets.cloudflare.file = "${self}/secrets/cloudflare.age";
    secrets.rclone.file = "${self}/secrets/rclone.age";
    secrets.sourcegraph.file = "${self}/secrets/sourcegraph.age";
    secrets.copilot.file = "${self}/secrets/copilot.fish.age";
  };
}
