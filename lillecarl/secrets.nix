{ config, ... }:
{
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/agenix"
    ];
    secrets.cloudflare.file = ../secrets/cloudflare.age;
  };
}
