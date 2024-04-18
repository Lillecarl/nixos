{ config, flakepath, ... }:
{
  age.secrets.cloudflare = {
    file = flakepath + ./secrets/cloudflare.age;
    inherit (config.users.users.acme) name group;
  };
}
