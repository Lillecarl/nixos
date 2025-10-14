{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
{
  flake.repl =
    let
      host = builtins.getEnv "HOST";
      user = builtins.getEnv "USER";
    in
    rec {
      pkgs = withSystem builtins.currentSystem ({ pkgs, ... }: pkgs);
      fmt = inputs.treefmt-nix.lib.evalModule pkgs ../fmt/default.nix;
      lib = pkgs.lib;
      inherit self inputs;

      os = self.nixosConfigurations.${host} or { };
      home = self.homeConfigurations."${user}@${host}" or { };
      gw = self.nixosConfigurations.gw1 or { };
      j2 = pkgs.writeJinja2.override {
        name = null;
        template = null;
        variables = null;
        environment = {
          lstrip_blocks = true;
          trim_blocks = true;
        };
      };
      render = pkgs.writeSaneJinja2 {
        name = "testtemplate";
        template = # j2
          ''
            {% for aline in alist %}
            {{ aline }}
            {% endfor %}
          '';
        # template = pkgs.writeTextFile {
        #   name = "template";
        #   text = ''
        #     {% for aline in alist %}
        #     {{ aline }}
        #     {% endfor %}
        #   '';
        # };
        variables = {
          alist = [
            "something"
            "else"
            "entirely"
          ];
        };
        # environment = {
        #   lstrip_blocks = true;
        #   trim_blocks = true;
        # };
      };
      ov = rec {
        func1 =
          { q, w }:
          {
            result = q + w;
          };
        func2 = lib.makeOverridable func1 {
          q = 1;
          w = 2;
        };
      };
      testFetchTree = builtins.fetchTree {
        type = "github";
        repo = "nixpkgs";
        owner = "NixOS";
        ref = "master";
      };
    };
}
