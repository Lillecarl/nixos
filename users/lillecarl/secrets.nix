{ self, config, ... }:
{
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/agenix"
    ];
    secrets.cloudflare.file = "${self}/secrets/cloudflare.age";
    secrets.rclone.file = "${self}/secrets/rclone.age";
    secrets.sourcegraph.file = "${self}/secrets/sourcegraph.age";
    secrets.copilot.file = "${self}/secrets/copilot.fish.age";
  };

  systemd.user.tmpfiles.rules = [
    #"L /home/user/Documents - - - - /mnt/data/Documents"
  ];
}
