{ pkgs, ... }:
pkgs.buildEnv {
  name = "flaketest";
  paths = [
    pkgs.salt
  ];
}
