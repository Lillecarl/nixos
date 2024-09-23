{ pkgs, inputs, ... }:
{
  imports = [ inputs.noshell.nixosModules.default ];

  programs.noshell = {
    enable = true;
  };

  users.users.root = {
    shell = pkgs.bashInteractive;
  };
}
