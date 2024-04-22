{ config, ... }:
{
  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = false;

    #extraPlugins = with pkgs.postgresql.pkgs; [
    extraPlugins = with config.services.postgresql.package.pkgs; [
      timescaledb
    ];
  };
}
