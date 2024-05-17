{ config, self, ... }:
{
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/agenix"
    ];
    secrets.sshKey.file = "${self}/secrets/root_ssh.age";
  };
}
