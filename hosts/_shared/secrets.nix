{ config, ... }:
{
  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare.age;
    inherit (config.users.users.acme) name group;
  };
}
