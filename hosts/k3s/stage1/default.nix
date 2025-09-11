{
  repl ? false,
}:
let
  fc = import ../../../default.nix;
  kubenix = import fc.inputs.kubenix;
  # terranixCore = "${fc.inputs.terranix}/core";
  terranixCore = "/home/lillecarl/Code/terranix/core";
  pkgs = fc.legacyPackages.${builtins.currentSystem};
  lib = pkgs.lib;

  kubenixEval = (
    kubenix.evalModules.${builtins.currentSystem} {
      module =
        { kubenix, ... }:
        {
          imports = [
            ./kubenix.nix
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
        kubenixAttrs = kubenixEval.config.kubernetes.generated;
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
    pkgs = pkgs;
    lib = lib;
  }
else
  pkgs.writeScript "terrakubenix" # fish
    (
      let
        fish = lib.getExe pkgs.fish;
        vals = lib.getExe pkgs.vals;
        jq = lib.getExe pkgs.jq;
        tofu = lib.getExe pkgs.opentofu;
        envsubst = lib.getExe pkgs.envsubst;
        gomplate = lib.getExe pkgs.gomplate;
        sed = lib.getExe pkgs.gnused;
      in #fish
      ''
        #! ${fish}
        set FILE ./config.tf.json
        rm -f $FILE
        cat ${terranixJsonPackage} | ${sed} "s/%%HCLOUD_TOKEN%%/$HCLOUD_TOKEN/g" | ${jq} > $FILE
        if test -f $FILE
          ${tofu} $argv -parallelism=1337 || return $status
        else
          echo "No config.tf.json found bro"
          return 1
        end
      ''
    )
