{ config, self, ... }:
{
  #home.file.".ssh/id_ed25519".source = config.age.secrets.sshKey.path;
  home.file.".ssh/id_ed25519.pub".source = "${self}/secrets/rootkey.pub";
}
