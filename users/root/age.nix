{ config, self, ... }:
{
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/agenix"
    ];
    secrets.sshKey = {
      file = "${self}/secrets/root_ssh.age";
      path = "/root/.ssh/id_ed25519";
      symlink = false;
    };
  };
}
