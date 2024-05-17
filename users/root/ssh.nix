{ config, self, ...}:
{
  home.file.".ssh/id_ed25519".source = "${self}/secrets/rootkey.pub";
  home.file.".ssh/id_ed25519.pub".source = config.age.secrets.sshKey.path;
}
