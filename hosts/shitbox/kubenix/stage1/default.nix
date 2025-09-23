{
  repl ? false,
}:
let
  flake = import ../../../../default.nix;
  kubenix = import flake.inputs.kubenix;
  terranixCore = "${flake.inputs.terranix}/core";
  pkgs = flake.legacyPackages.${builtins.currentSystem};
  lib = pkgs.lib;

  kubenixEval = (
    kubenix.evalModules.${builtins.currentSystem} {
      module =
        { kubenix, ... }:
        {
          imports = [
            kubenix.modules.k8s
            kubenix.modules.helm
            ./cilium.nix
            ./coredns.nix
            ./nginx.nix
            ./local-path-provisioner.nix
          ];
        };
    }
  );
  terranixEval = (
    import terranixCore {
      inherit pkgs;
      terranix_config = {
        imports = [ ./terranix.nix ];
      };
      extraArgs = {
        kubenixJSON = kubenixEval.config.kubernetes.result;
        kubenixYAML = kubenixEval.config.kubernetes.resultYAML;
      };
      strip_nulls = true;
    }
  );

  terranixJson = builtins.toJSON terranixEval.config;
  # terranixJsonFile = (pkgs.formats.json { }).generate "config.tf.json" terranixCore.config;
  terranixJsonPackage = pkgs.writeTextFile {
    name = "config.tf.json";
    text = terranixJson;
  };
in
if repl then
  {
    kn = kubenixEval;
    tn = terranixEval;
  }
else
  pkgs.writeScript "terrakubenix" # fish
    ''
      #! ${pkgs.lib.getExe pkgs.fish}
      rm -f ./config.tf.json
      cp ${terranixJsonPackage} ./config.tf.json
      if test -f ./config.tf.json
        ${lib.getExe pkgs.opentofu} $argv || return $status
      else
        echo "No config.tf.json found bro"
        return 1
      end
    ''
