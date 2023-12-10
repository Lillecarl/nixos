{ inputs
, ...
}: {
  perSystem =
    { config
    , self'
    , inputs'
    , pkgs
    , system
    , ...
    }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [ ./config.nix ];
      };
      tfrun = command:
        toString (pkgs.writers.writeBash command ''
          if [[ -e ./terraform/config.tf.json ]]; then rm -f ./terraform/config.tf.json; fi
          cp ${terraformConfiguration} ./terraform/config.tf.json \
            && ${pkgs.terraform}/bin/terraform -chdir="./terraform" init \
            && ${pkgs.terraform}/bin/terraform -chdir="./terraform" ${command}
        '');
    in
    {
      apps = {
        apply = {
          type = "app";
          program = tfrun "apply";
        };
        # nix run ".#destroy"
        destroy = {
          type = "app";
          program = tfrun "destroy";
        };
      };
    };
}
