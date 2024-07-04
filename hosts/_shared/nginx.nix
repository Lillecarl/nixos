{ config, ... }:
{
  services.nginx.enable = true;
  users.users.nginx.extraGroups = [
    config.security.acme.defaults.group
  ];
}
